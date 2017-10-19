TabPackage = require "../lib/main"

{expectNotExist, expectExist} = require "./tools"

pkg = require("../package.json").name
FIXTURES_FOLDER = "fixtures"

checkHiddenOriginalTitle = (workspaceElement) ->
  originalTitle = workspaceElement.querySelector ".#{pkg}__original"
  expectExist originalTitle
  expect(originalTitle.offsetWidth).toBe 0


describe "Tab-foldername-index main", ->
  workspaceElement = null

  beforeEach ->
    atom.config.set('tab-foldername-index.equalsNamesEnabled', true)
    atom.config.set('tab-foldername-index.numberOfFolders', 1)
    workspaceElement = atom.views.getView atom.workspace
    jasmine.attachToDOM workspaceElement

    waitsForPromise ->
      atom.packages.activatePackage "tabs"

  it "should render index.js", ->
    waitsForPromise ->
      atom.workspace.open "index.js"
      .then ->
        atom.packages.activatePackage pkg,

    runs ->
      $tab = workspaceElement.querySelector ".#{pkg}"
      expectExist $tab
      expect($tab.offsetWidth).toBeGreaterThan 0
      expect($tab.querySelector(".#{pkg}__folder").textContent).toBe FIXTURES_FOLDER
      expect($tab.querySelector(".#{pkg}__file").textContent).toBe "index.js"
      checkHiddenOriginalTitle workspaceElement

  it "should render index.js after second opening", ->
    waitsForPromise ->
      atom.workspace.open "index.js"
      .then ->
        atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "index.js"

    runs ->
      $tab = workspaceElement.querySelector ".#{pkg}"
      expectExist $tab
      expect($tab.offsetWidth).toBeGreaterThan 0
      expect($tab.querySelector(".#{pkg}__folder").textContent).toBe FIXTURES_FOLDER
      expect($tab.querySelector(".#{pkg}__file").textContent).toBe "index.js"
      checkHiddenOriginalTitle workspaceElement

  it "should render index.png", ->
    waitsForPromise ->
      atom.workspace.open "index.png"
      .then ->
        atom.packages.activatePackage pkg

    runs ->
      $tab = workspaceElement.querySelector ".#{pkg}"
      expectExist $tab
      expect($tab.offsetWidth).toBeGreaterThan 0
      expect($tab.querySelector(".#{pkg}__folder").textContent).toBe FIXTURES_FOLDER
      expect($tab.querySelector(".#{pkg}__file").textContent).toBe "index.png"
      checkHiddenOriginalTitle workspaceElement

  it "should render index.js when opened file after activate plugin", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "index.js"

    waits 20

    runs ->
      $tab = workspaceElement.querySelector ".#{pkg}"
      expectExist $tab
      expect($tab.offsetWidth).toBeGreaterThan 0
      expect($tab.querySelector(".#{pkg}__folder").textContent).toBe FIXTURES_FOLDER
      expect($tab.querySelector(".#{pkg}__file").textContent).toBe "index.js"
      checkHiddenOriginalTitle workspaceElement

  it "should not render sample.js", ->
    waitsForPromise ->
      atom.workspace.open "sample.js"
      .then ->
        atom.packages.activatePackage pkg

    runs ->
      expect(workspaceElement.querySelector ".#{pkg}").not.toExist()

  it "should not render sample.js when opened file after activate plugin", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "sample.js"

    waits 20

    runs ->
      expectNotExist workspaceElement.querySelector ".#{pkg}",
        workspaceElement.querySelector ".#{pkg}__original"

  it "should reset default tab render after deactivate plugin", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "index.js"

    waits 20

    runs ->
      atom.packages.deactivatePackage pkg
      expectNotExist workspaceElement.querySelector ".#{pkg}",
        workspaceElement.querySelector ".#{pkg}__original"

  it "should reset default tab render after toggle(from active state) command", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "index.js"

    waits 20

    runs ->
      atom.commands.dispatch workspaceElement, "tab-foldername-index:toggle"
      expectNotExist workspaceElement.querySelector ".#{pkg}",
        workspaceElement.querySelector ".#{pkg}__original"

  it "should remember package state after deactivating", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "index.js"
      .then ->
        atom.commands.dispatch workspaceElement, "tab-foldername-index:toggle"
        atom.packages.disablePackage pkg
      .then ->
        atom.packages.activatePackage pkg

    waits 20

    runs ->
      expectNotExist workspaceElement.querySelector ".#{pkg}",
        workspaceElement.querySelector ".#{pkg}__original"

  it "should reset render styled tabs after toggle(from disable state) command", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.commands.dispatch workspaceElement, "tab-foldername-index:toggle"
        atom.workspace.open "index.js"

    waits 20

    runs ->
      atom.commands.dispatch workspaceElement, "tab-foldername-index:toggle"
      expectExist workspaceElement.querySelector ".#{pkg}",
        workspaceElement.querySelector ".#{pkg}__original"

  it "should cut long folder name", ->
    waitsForPromise ->
      atom.workspace.open "/index.js"
      .then ->
        atom.packages.activatePackage pkg

    runs ->
      folderBlock = workspaceElement.querySelector ".#{pkg}__folder"
      folderBlock.textContent = "very_looooooooooooooooooooooooooooooong name"
      expect(folderBlock.offsetWidth).not.toBeGreaterThan workspaceElement.querySelector(".tab").offsetWidth


describe "Tab-foldername-index main activated before tabs", ->
  it "should render index.js when opened tabs plugin activated after #{pkg}", ->
    workspaceElement = atom.views.getView atom.workspace

    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "index.js"
      .then ->
        atom.packages.activatePackage "tabs"

    waits 20

    runs ->
      jasmine.attachToDOM workspaceElement
      $tab = workspaceElement.querySelector ".#{pkg}"
      expectExist $tab
      expect($tab.offsetWidth).toBeGreaterThan 0
      expect($tab.querySelector(".#{pkg}__folder").textContent).toBe FIXTURES_FOLDER
      expect($tab.querySelector(".#{pkg}__file").textContent).toBe "index.js"
      checkHiddenOriginalTitle workspaceElement
