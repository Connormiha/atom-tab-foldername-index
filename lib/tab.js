/**
 * Creates div element
 * @param {Object} params
 * @return {HTMLElement}
 */
function div(params) {
    let item = document.createElement('div');

    for (let key of Object.keys(params)) {
        item[key] = params[key];
    }

    return item;
}

/**
 * Generates DOM element
 * @param {String} folder
 * @param {String} file
 * @return {HTMLElement}
 */
function generateTabTitle(folder, file) {
    let $block = div({
        className: CLASS_NAME
    });
    let $folderBlock = div({
        className: `${CLASS_NAME}__folder`,
        textContent: folder
    });
    let $fileBlock = div({
        className: `${CLASS_NAME}__file`,
        textContent: file
    });
    let $wrapper = div({
        className: `${CLASS_NAME}__wrapper`
    });

    $wrapper.appendChild($folderBlock);
    $wrapper.appendChild($fileBlock);
    $block.appendChild($wrapper);
    return $block;
}

// Only for tests, because Jasmine mocks setTimeout
const realTimeout = window.setTimeout;

const CLASS_NAME = 'tab-foldername-index';
const regExpIndexName = /^(index\.(\w{1,8}\.)?\w+|__init__\.(py|php))$/;

class Tab {
    /**
     * @param {Pane} pane
     * @param {HTMLElement} $element
     */
    constructor(pane, $element) {
        // Activate by setEnabled method
        this.pane = pane;
        this.setDomElement($element);
        this.disabled = true;

        if (this.pane.onDidChangePath) {
            this.handleChange = this.pane.onDidChangePath(realTimeout.bind(null, this.checkTab.bind(this)));
        } else if (this.pane.file && this.pane.file.onDidRename) {
            this.handleChange = this.pane.file.onDidRename(realTimeout.bind(null, this.checkTab.bind(this)));
        }
    }

    /**
     * Sets tab enabled
     */
    setEnabled() {
        this.disabled = false;
        this.checkTab();
    }

    /**
     * Sets tab disabled
     */
    setDisabled() {
        this.disabled = true;
        this.clearTab();
    }

    /**
     * Sets link to DOM element
     * @param {HTMLElement} $element
     */
    setDomElement($element) {
        this.$element = $element;
    }

    /**
     * Removes handler changes
     */
    destroy() {
        this.handleChange.dispose();
        this.handleChange = null;
    }

    /**
     * Checks tab. If path valid, render title else clear old title
     */
    checkTab() {
        const name = this.pane.getTitle();

        if (this.disabled || !regExpIndexName.test(name)) {
            this.clearTab();
            return;
        }

        let folder = this.pane.getPath().split('/');
        folder = folder[folder.length - 2];

        let $tabWrapper = generateTabTitle(folder, name);
        let $oldTabWrapper = this.$element.querySelector(`.${CLASS_NAME}`);

        if ($oldTabWrapper) {
            $oldTabWrapper.remove();
        }

        const $title = this.$element.querySelector('.title');
        $title.parentNode.appendChild($tabWrapper);

        $title.classList.add(`${CLASS_NAME}__original`);
    }

    /*
     * Removes styled title and restore original title
     */
    clearTab() {
        let $title = this.$element.querySelector('.title');

        $title.classList.remove(`${CLASS_NAME}__original`);

        let $wrapper = this.$element.querySelector(`.${CLASS_NAME}`);

        if ($wrapper) {
            $wrapper.remove();
        }
    }
}

module.exports = Tab;
