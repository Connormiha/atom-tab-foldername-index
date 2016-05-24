TabPackage = require "../lib/main"
Tab = require "../lib/tab"
{expectNotExist, expectExist} = require "./tools"

pkg = require("../package.json").name

checkHiddenOriginalTitle = (workspaceElement) ->
  originalTitle = workspaceElement.querySelector ".#{Tab::className}__original"
  expectExist originalTitle
  expect(originalTitle.offsetWidth).toBe 0


describe "Tab-foldername-index main", ->
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView atom.workspace
    jasmine.attachToDOM workspaceElement

    waitsForPromise ->
      atom.packages.activatePackage "tabs"

  it "should render index.js", ->
    waitsForPromise ->
      atom.workspace.open "index.js"
      .then ->
        atom.packages.activatePackage pkg

    runs ->
      $tab = workspaceElement.querySelector ".#{Tab::className}"
      expectExist $tab
      expect($tab.offsetWidth).toBeGreaterThan 0
      expect($tab.querySelector(".#{Tab::className}__folder").textContent).toBe "spec"
      expect($tab.querySelector(".#{Tab::className}__file").textContent).toBe "index.js"
      checkHiddenOriginalTitle workspaceElement

  it "should render index.js when opened file after activate plugin", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "index.js"

    waits 20

    runs ->
      $tab = workspaceElement.querySelector ".#{Tab::className}"
      expectExist $tab
      expect($tab.offsetWidth).toBeGreaterThan 0
      expect($tab.querySelector(".#{Tab::className}__folder").textContent).toBe "spec"
      expect($tab.querySelector(".#{Tab::className}__file").textContent).toBe "index.js"
      checkHiddenOriginalTitle workspaceElement

  it "should not render sample.js", ->
    waitsForPromise ->
      atom.workspace.open "sample.js"
      .then ->
        atom.packages.activatePackage pkg

    runs ->
      expect(workspaceElement.querySelector ".#{Tab::className}").not.toExist()

  it "should not render sample.js when opened file after activate plugin", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "sample.js"

    waits 20

    runs ->
      expectNotExist workspaceElement.querySelector ".#{Tab::className}",
        workspaceElement.querySelector ".#{Tab::className}__original"

  it "should reset default tab render after deactivate plugin", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "index.js"

    waits 20

    runs ->
      atom.packages.deactivatePackage pkg
      expectNotExist workspaceElement.querySelector ".#{Tab::className}",
        workspaceElement.querySelector ".#{Tab::className}__original"

  it "should reset default tab render after toggle(from active state) command", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.workspace.open "index.js"

    waits 20

    runs ->
      atom.commands.dispatch workspaceElement, "tab-foldername-index:toggle"
      expectNotExist workspaceElement.querySelector ".#{Tab::className}",
        workspaceElement.querySelector ".#{Tab::className}__original"

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
      expectNotExist workspaceElement.querySelector ".#{Tab::className}",
        workspaceElement.querySelector ".#{Tab::className}__original"

  it "should reset render styled tabs after toggle(from disable state) command", ->
    waitsForPromise ->
      atom.packages.activatePackage pkg
      .then ->
        atom.commands.dispatch workspaceElement, "tab-foldername-index:toggle"
        atom.workspace.open "index.js"

    waits 20

    runs ->
      atom.commands.dispatch workspaceElement, "tab-foldername-index:toggle"
      expectExist workspaceElement.querySelector ".#{Tab::className}",
        workspaceElement.querySelector ".#{Tab::className}__original"

  it "should cut long folder name", ->
    waitsForPromise ->
      atom.workspace.open "/index.js"
      .then ->
        atom.packages.activatePackage pkg

    runs ->
      folderBlock = workspaceElement.querySelector ".#{Tab::className}__folder"
      folderBlock.textContent = "very_looooooooooooooooooooooooooooooong name";
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
      $tab = workspaceElement.querySelector ".#{Tab::className}"
      expectExist $tab
      expect($tab.offsetWidth).toBeGreaterThan 0
      expect($tab.querySelector(".#{Tab::className}__folder").textContent).toBe "spec"
      expect($tab.querySelector(".#{Tab::className}__file").textContent).toBe "index.js"
      checkHiddenOriginalTitle workspaceElement
