TabPackage = require "../lib/main"
Tab = require "../lib/tab"

pkg = require("../package.json").name

describe "Tab-foldername-index main", ->
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)

    waitsForPromise ->
      atom.packages.activatePackage("tabs")

  it "should render index.js", ->
    waitsForPromise ->
      atom.workspace.open('index.js')
      .then ->
        atom.packages.activatePackage(pkg)

    runs ->
      $tab = workspaceElement.querySelector ".#{Tab::className}"
      expect($tab).toExist()
      expect($tab.querySelector(".#{Tab::className}__folder").textContent).toBe("spec")
      expect($tab.querySelector(".#{Tab::className}__file").textContent).toBe("index.js")

  it "should render index.js then opened file after activate plugin", ->
    waitsForPromise ->
      atom.packages.activatePackage(pkg)
      .then ->
        atom.workspace.open('index.js')

    waits 20

    runs ->
      $tab = workspaceElement.querySelector ".#{Tab::className}"
      expect($tab).toExist()
      expect($tab.querySelector(".#{Tab::className}__folder").textContent).toBe("spec")
      expect($tab.querySelector(".#{Tab::className}__file").textContent).toBe("index.js")

  it "should not render sample.js", ->
    waitsForPromise ->
      atom.workspace.open('sample.js')
      .then ->
        atom.packages.activatePackage(pkg)

    runs ->
      expect(workspaceElement.querySelector ".#{Tab::className}").not.toExist()

  it "should not render sample.js then opened file after activate plugin", ->
    waitsForPromise ->
      atom.packages.activatePackage(pkg)
      .then ->
        atom.workspace.open('sample.js')

    waits 20

    runs ->
      expect(workspaceElement.querySelector ".#{Tab::className}").not.toExist()
