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

const tabs = new Map();

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

        tabs.clear();

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

            for (const key of tabs) {
                key[1].checkTab();
            }
        }));

        this.subscriptions.add(atom.config.onDidChange('tab-foldername-index.numberOfFolders', () => {
          for (const key of tabs) {
              key[1].checkTab();
          }
        }));
    },

    /**
     * Runs ones, on packges is ready
     */
    init() {
        this.disposables = new CompositeDisposable();
        this.disposables.add(atom.workspace.onDidAddPaneItem((e) => {
            this._addTabTimeout = realTimeout(() => this.addTab(e.item))
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

        if (tabs.has(pane)) {
            let cssPath = getCssPath(path);
            let items = getPaneElement(cssPath);

            if (items.length) {
                const currentTab = tabs.get(pane);
                // Let's set new DOM element for tab
                currentTab.setDomElement(items);

                if (this.active) {
                    currentTab.setEnabled();
                }
            }

            return;
        }

        let cssPath = getCssPath(path);
        let items = getPaneElement(cssPath);

        if (!items.length) {
            return;
        }

        let currentTab = new Tab(pane, items);
        tabs.set(pane, currentTab);

        let removeDispose;

        if (pane.onDidDestroy) {
            // ImageEditor doesn't destroy when close tab
            removeDispose = pane.onDidDestroy(() => {
                removeDispose.dispose();
                this.handleTabRemove(pane);
                pane = null;
                removeDispose = null;
            });

            this.subscriptions.add(removeDispose);
        }

        if (this.active) {
            currentTab.setEnabled();
        }

        currentTab = null;
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
     * @param {Pane} pane
     */
    handleTabRemove(pane) {
        const currentTab = tabs.get(pane);

        if (currentTab) {
            currentTab.destroy();
        }

        tabs.delete(pane);
    },

    /**
     * Create styles tabs, unsubscribes handlers
     */
    deactivate() {
        clearTimeout(this._addTabTimeout);
        this.setDisabled();
        for (const [pane] of tabs) {
            this.handleTabRemove(pane);
        }

        this.subscriptions.dispose();
        this.subscriptions = null;
        this.removeDropEventListener();

        if (this.disposables) {
            this.disposables.dispose();
        }
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
        for (const key of tabs) {
            key[1].setEnabled();
        }
    },

    /**
     * Removes package's tab style from all tabs
     */
    setDisabled() {
        for (const key of tabs) {
            key[1].setDisabled();
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
