TabPackage = require "../lib/main"
Tab = require "../lib/tab"

pkg = require("../package.json").name

checkHiddenOriginalTitle = (workspaceElement) ->
  originalTitle = workspaceElement.querySelector ".#{Tab::className}__original"
  expect(originalTitle).toExist()
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
      expect($tab).toExist()
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
      expect($tab).toExist()
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
      expect(workspaceElement.querySelector ".#{Tab::className}").not.toExist()
      expect(workspaceElement.querySelector ".#{Tab::className}__original").not.toExist()

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
      expect($tab).toExist()
      expect($tab.offsetWidth).toBeGreaterThan 0
      expect($tab.querySelector(".#{Tab::className}__folder").textContent).toBe "spec"
      expect($tab.querySelector(".#{Tab::className}__file").textContent).toBe "index.js"
      checkHiddenOriginalTitle workspaceElement
