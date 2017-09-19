const mapNames = require('./mapNames');
const pathSep = require('path').sep;

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

const iconClassNameRegExp = /^(\w+-)?icon$/;
const mediumClassNameRegExp = /^medium-\w+$/;

function removeNotIconsClasses(classes) {
    let result = '';

    for (let item of classes.split(' ')) {
        if (iconClassNameRegExp.test(item) || mediumClassNameRegExp.test(item)) {
            result+= `${item} `;
        }
    }

    return result.slice(0, -1);
}

/**
 * Generates DOM element
 * @param {String} folder
 * @param {String} file
 * @return {HTMLElement}
 */
function generateTabTitle(folder, file, initialClasses) {
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
    let $textWrapper = div({
        className: `${CLASS_NAME}__text-wrapper`
    });
    let $flexWrapper = div({
        className: `${CLASS_NAME}__flex-wrapper ${removeNotIconsClasses(initialClasses)}`
    });

    $textWrapper.appendChild($folderBlock);
    $textWrapper.appendChild($fileBlock);
    $flexWrapper.appendChild($textWrapper);
    $block.appendChild($flexWrapper);
    return $block;
}

// Only for tests, because Jasmine mocks setTimeout
const realTimeout = window.setTimeout;

const CLASS_NAME = 'tab-foldername-index';
const regExpIndexName = /^(index\.(\w{1,8}\.)?\w+|__init__\.(py|php))$/;

class Tab {
    /**
     * @param {Pane} pane
     * @param {HTMLElement[]} $elements
     */
    constructor(pane, $elements) {
        // Activate by setEnabled method
        this.pane = pane;
        this.setDomElement($elements);
        this.disabled = true;
        this.name = this.pane.getTitle();

        this.handleMapNamesChange = this.handleMapNamesChange.bind(this);

        if (this.pane.onDidChangePath) {
            this.handleChange = this.pane.onDidChangePath(realTimeout.bind(null, this.handleRename.bind(this)));
        } else if (this.pane.file && this.pane.file.onDidRename) {
            this.handleChange = this.pane.file.onDidRename(realTimeout.bind(null, this.handleRename.bind(this)));
        }
    }

    handleRename() {
        mapNames.remove(this.name);
        this.name = this.pane.getTitle();
        this.addToMap();
        this.checkTab();
    }

    handleMapNamesChange(name) {
        if (this.name === name) {
            this.checkTab();
        }
    }

    addToMap() {
        if (!regExpIndexName.test(this.name)) {
            mapNames.add(this.name);
        }
    }

    /**
     * Sets tab enabled
     */
    setEnabled() {
        this.disabled = false;
        mapNames.add(this.name);
        mapNames.addListener(this.handleMapNamesChange);
        this.checkTab();
    }

    /**
     * Sets tab disabled
     */
    setDisabled() {
        this.disabled = true;
        this.clearTab();
        mapNames.removeListener(this.handleMapNamesChange);
        mapNames.remove(this.name);
    }

    /**
     * Sets link to DOM element
     * @param {HTMLElement} $elements
     */
    setDomElement($elements) {
        this.$elements = $elements;
    }

    /**
     * Removes handler changes
     */
    destroy() {
        this.handleChange.dispose();
        this.handleChange = null;
        this.$elements = null;

        if (!this.disabled) {
            mapNames.removeListener(this.handleMapNamesChange);
            mapNames.remove(this.name);
        }
    }

    /**
     * Checks tab. If path valid, render title else clear old title
     */
    checkTab() {
        const name = this.pane.getTitle();

        if (
            this.disabled ||
            (
                !regExpIndexName.test(name) &&
                (!atom.config.get('tab-foldername-index.equalsNamesEnabled') || !mapNames.hasReapeatedNames(name))
            )
        ) {
            this.clearTab();
            return;
        }

        let folder = this.pane.getPath().split(pathSep);
        const numOfFolders = atom.config.get('tab-foldername-index.numberOfFolders');
        folder = folder.slice(folder.length - numOfFolders - 1, -1).join(pathSep);

        for (let $element of this.$elements) {
            const $title = $element.querySelector('.title');

            let $tabWrapper = generateTabTitle(folder, name, $title.className);
            let $oldTabWrapper = $element.querySelector(`.${CLASS_NAME}`);

            if ($oldTabWrapper) {
                $oldTabWrapper.remove();
            }

            $title.parentNode.appendChild($tabWrapper);

            $title.classList.add(`${CLASS_NAME}__original`);
        }
    }

    /*
     * Removes styled title and restore original title
     */
    clearTab() {
        for (let $element of this.$elements) {
            let $title = $element.querySelector('.title');

            $title.classList.remove(`${CLASS_NAME}__original`);

            let $wrapper = $element.querySelector(`.${CLASS_NAME}`);

            if ($wrapper) {
                $wrapper.remove();
            }
        }
    }
}

module.exports = Tab;
