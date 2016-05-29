const CompositeDisposable = require('atom').CompositeDisposable;

const Tab = require('./tab');

const realTimeout = window.setTimeout;

module.exports = {
    /**
     * Runs on avtive plugin
     * @param {Object} state
     */
    activate(state) {
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

        if (!path || this.tabs[pane.id]) {
            return;
        }

        let cssPath = path.replace(/\\/g, '\\\\').replace(/\"/g, "\\\"");
        let item = atom.views.getView(atom.workspace).querySelector(`.tab .title[data-path=\"${cssPath}\"]`);

        if (!item) {
            return;
        }

        this.tabs[pane.id] = new Tab(pane, item.parentNode);
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

    deactivate() {
        this.setDisabled();
        for (let id of Object.keys(this.tabs)) {
            this.handleTabRemove(id);
        }

        this.subscriptions.dispose();
    },

    serialize() {
        return {
            active: this.active
        };
    },

    setEnabled() {
        for (let id of Object.keys(this.tabs)) {
            this.tabs[id].setEnabled();
        }
    },

    setDisabled() {
        for (let id of Object.keys(this.tabs)) {
            this.tabs[id].setDisabled();
        }
    },

    toggle() {
        this.active = !this.active

        this.active ? this.setEnabled() : this.setDisabled();
    }
};
