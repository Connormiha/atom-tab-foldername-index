const {CompositeDisposable} = require('atom');
const Tab = require('./tab');
const realTimeout = window.setTimeout;

const REG_EXP_SLASH = /\\/g;
const REG_EXP_QUOTE = /"/g;

/**
 * Normalizers path
 * @param {String} path
 * @return {String}
 */
const getCssPath = (path) => {
    return path.replace(REG_EXP_SLASH, '\\\\').replace(REG_EXP_QUOTE, "\\\"");
}

/**
 * Finds all tabs for current path file
 * @param {String} cssPath
 * @return {HTMLElement[]}
 */
const getPaneElement = (cssPath) => {
    return Array.prototype.map.call(
        atom.views.getView(atom.workspace)
            .querySelectorAll(`.tab .title[data-path="${cssPath}"]`), ({parentNode}) => parentNode);
};

let tabs;

module.exports = {
    config: {
        equalsNamesEnabled: {
            type: 'boolean',
            default: true,
            title: 'Match tabs with same name',
            description: 'When opened 2 and more files with same name but from different folders it will styled always(even if name doesn\'t match pattern index.* ).',
        },
        numberOfFolders: {
          type: 'integer',
          default: 1,
          description: 'Number of folders to display'
        }
    },
    /**
     * Runs on avtive plugin
     * @param {Object} state
     */
    activate(state) {
        state = state || {};
        this.handleDropTab = this.handleDropTab.bind(this);

        this.active = state.active !== false;
        // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        this.subscriptions = new CompositeDisposable();

        // Register command that toggles this view
        this.subscriptions.add(
            atom.commands.add(
                'atom-workspace', {
                    'tab-foldername-index:toggle': () => this.toggle()
                }
            )
        );

        tabs = {};

        if (atom.packages.isPackageActive('tabs')) {
            this.init();
        } else {
            let onceActivated = atom.packages.onDidActivatePackage((item) => {
                if (item.name === 'tabs') {
                    onceActivated.dispose();
                    this.init();
                }
            });
        }

        this.addConfigChangeHandler();
    },

    addConfigChangeHandler() {
        this.subscriptions.add(atom.config.onDidChange('tab-foldername-index.equalsNamesEnabled', () => {
            if (!this.active) {
                return;
            }

            for (const tab in tabs) {
                if (tabs.hasOwnProperty(tab)) {
                    tabs[tab].checkTab();
                }
            }
        }));

        this.subscriptions.add(atom.config.onDidChange('tab-foldername-index.numberOfFolders', () => {
          for (const tab in tabs) {
              if (tabs.hasOwnProperty(tab)) {
                  tabs[tab].checkTab();
              }
          }
        }));
    },

    /**
     * Runs ones, on packges is ready
     */
    init() {
        this.disposables = new CompositeDisposable();
        this.disposables.add(atom.workspace.onDidAddPaneItem((e) => {
            realTimeout(() => this.addTab(e.item))
        }));

        this.addAllTabs();
        this.addDropEventListener();
    },

    addAllTabs() {
        const panes = atom.workspace.getPaneItems();

        for (const item of panes) {
            this.addTab(item);
        }
    },

    /**
     * Adds panel for styling
     * @param {Panel}
     */
    addTab(pane) {
        let path = typeof(pane.getPath) === 'function' ? pane.getPath() : null;

        if (!path) {
            return;
        }

        if (!pane.getFileName && !pane.file) {
            return;
        }

        if (tabs[pane.id]) {
            let cssPath = getCssPath(path);
            let items = getPaneElement(cssPath);

            if (items.length) {
                // Let's set new DOM element for tab
                tabs[pane.id].setDomElement(items);

                if (this.active) {
                    tabs[pane.id].setEnabled();
                }
            }

            return;
        }

        let cssPath = getCssPath(path);
        let items = getPaneElement(cssPath);

        if (!items.length) {
            return;
        }

        tabs[pane.id] = new Tab(pane, items);

        const {id} = pane;
        let removeDispose;

        if (pane.onDidDestroy) {
            // ImageEditor doesn't destroy when close tab
            removeDispose = pane.onDidDestroy(() => {
                removeDispose.dispose();
                this.handleTabRemove(id);
            });

            this.subscriptions.add(removeDispose);
        }

        if (this.active) {
            tabs[id].setEnabled();
        }

        pane = null;
    },

    /**
     * Adds listener for drop events
     */
    addDropEventListener() {
        atom.views.getView(atom.workspace).addEventListener('drop', this.handleDropTab, true);
    },

    /**
     * Removes listener for drop events
     */
    removeDropEventListener() {
        atom.views.getView(atom.workspace).removeEventListener('drop', this.handleDropTab, true);
    },

    /**
     * Handeles drop tab event
     * @param {Event} e
     */
    handleDropTab(e) {
        if (e.dataTransfer && e.dataTransfer.getData('from-pane-index')) {
            realTimeout(() => this.addAllTabs());
        }
    },

    /**
     * Runs when close tab or destroyed package
     * @param {Number} id
     */
    handleTabRemove(id) {
        if (!tabs[id]) {
            return;
        }

        tabs[id].destroy();
        delete tabs[id];
    },

    /**
     * Create styles tabs, unsubscribes handlers
     */
    deactivate() {
        this.setDisabled();
        for (let id of Object.keys(tabs)) {
            this.handleTabRemove(id);
        }

        this.subscriptions.dispose();
        this.removeDropEventListener();
    },

    /**
     * Saves settings
     * @return {Object}
     */
    serialize() {
        return {
            active: this.active
        };
    },

    /**
     * Add package's tab style from all tabs
     */
    setEnabled() {
        for (let id of Object.keys(tabs)) {
            tabs[id].setEnabled();
        }
    },

    /**
     * Removes package's tab style from all tabs
     */
    setDisabled() {
        for (let id of Object.keys(tabs)) {
            tabs[id].setDisabled();
        }
    },

    /**
     * Toggles package (disable or enable)
     */
    toggle() {
        this.active = !this.active

        if (this.active) {
            this.setEnabled();
        } else {
            this.setDisabled();
        }
    }
};
