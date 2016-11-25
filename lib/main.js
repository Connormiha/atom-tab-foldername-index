const CompositeDisposable = require('atom').CompositeDisposable;
const Tab = require('./tab');
const realTimeout = window.setTimeout;

const REG_EXP_SLASH = /\\/g;
const REG_EXP_QUOTE = /\\/g;

const getCssPath = (path) => {
    return path.replace(REG_EXP_SLASH, '\\\\').replace(REG_EXP_QUOTE, "\\\"");
}

const getPaneElement = (cssPath) => {
    return atom.views.getView(atom.workspace).querySelectorAll(`.tab .title[data-path=\"${cssPath}\"]`);
};

module.exports = {
    /**
     * Runs on avtive plugin
     * @param {Object} state
     */
    activate(state) {
        state = state || {};

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

        this.tabs = {};

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
    },

    /**
     * Runs ones, on packges is ready
     */
    init() {
        this.disposables = new CompositeDisposable();
        this.disposables.add(atom.workspace.onDidAddPaneItem((e) => {
            realTimeout(() => this.addTab(e.item))
        }));

        let panes = atom.workspace.getPaneItems();
        for (let item of panes) {
            this.addTab(item);
        }
    },

    /**
     * Adds panel for styling
     * @param {Panel}
     */
    addTab(pane) {
        let path = typeof(pane.getPath) === 'function' ? pane.getPath() : null;

        if (!path || !pane.editorElement) {
            return;
        }

        if (this.tabs[pane.id]) {
            let cssPath = getCssPath(path);
            let item = getPaneElement(cssPath);

            if (item) {
                // Let's set new DOM element for tab
                this.tabs[pane.id].setDomElement(item.parentNode);
                this.tabs[pane.id].setEnabled();
            }

            return;
        }

        let cssPath = getCssPath(path);
        let item = getPaneElement(cssPath);

        if (!item) {
            return;
        }

        this.tabs[pane.id] = new Tab(pane, item.parentNode);

        // ImageEditor doesn't destroy when close tab
        removeDispose = pane.onDidDestroy(() => {
            removeDispose.dispose();
            this.handleTabRemove(pane.id);
        });

        this.subscriptions.add(removeDispose);
        if (this.active) {
            this.tabs[pane.id].setEnabled();
        }
    },

    /**
     * Runs when close tab or destroed package
     * @param {Number} id
     */
    handleTabRemove(id) {
        if (!this.tabs[id]) {
            return;
        }
        this.tabs[id].destroy();
        delete this.tabs[id];
    },

    /**
     * Create styles tabs, unsubscribes handlers
     */
    deactivate() {
        this.setDisabled();
        for (let id of Object.keys(this.tabs)) {
            this.handleTabRemove(id);
        }

        this.subscriptions.dispose();
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
        for (let id of Object.keys(this.tabs)) {
            this.tabs[id].setEnabled();
        }
    },

    /**
     * Removes package's tab style from all tabs
     */
    setDisabled() {
        for (let id of Object.keys(this.tabs)) {
            this.tabs[id].setDisabled();
        }
    },

    /**
     * Toggles package (disable or enable)
     */
    toggle() {
        this.active = !this.active

        this.active ? this.setEnabled() : this.setDisabled();
    }
};
