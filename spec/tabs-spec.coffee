Tabs = require "../lib/main"
{expectNotExist, expectExist, mockAtomGetView, restoreAtomGetView} = require "./tools"
pkg = require("../package.json").name
mapNames = require("../lib/mapNames")

describe "tab-foldername-index module", ->
  pkgModule = null
  originalAtomViewsGetView = atom.views.getView

  beforeEach ->
    atom.config.set("#{pkg}.equalsNamesEnabled", true)
    pkgModule = Object.assign {}, Tabs
    delete pkgModule.active
    delete pkgModule.subscriptions

  afterEach ->
    mapNames.clear()
    restoreAtomGetView()
    pkgModule.activate()
    pkgModule.deactivate()

  it "should toggle", ->
    pkgModule.active = true
    pkgModule.tabs = {}
    pkgModule.toggle()
    expect(pkgModule.active).toBe false

  it "should serialize", ->
    pkgModule.active = false
    expect(pkgModule.serialize()).toEqual active: false

    pkgModule.active = true
    expect(pkgModule.serialize()).toEqual active: true

  it "should activate", ->
    pkgModule.activate({})
    expect(pkgModule.active).toBe true

  describe "addTab", ->
    beforeEach ->
      pkgModule.subscriptions =
        add: ->

    it "shouldn't fail with pane without getPath", ->
      pkgModule.activate({})
      expect(-> pkgModule.addTab({})).not.toThrow()

    it "shouldn't fail with pane with empty path", ->
      pkgModule.activate({})
      expect(-> pkgModule.addTab({getPath: -> ""})).not.toThrow()

    it "should add two different panes", ->
      pane1 =
        getPath: -> 'foo/bar/index.js'
        onDidDestroy: ->
        getFileName: -> 'index.js'
        getTitle: -> 'index.js'
        id: 101

      pane2 =
        getPath: -> 'foo/bar/index.js'
        onDidDestroy: ->
        getFileName: -> 'index.js'
        getTitle: -> 'index.js'
        id: 201

      spyOn pane1, "onDidDestroy"
      spyOn pane2, "onDidDestroy"
      mockAtomGetView("foo/bar/index.js")

      pkgModule.addTab pane1
      pkgModule.addTab pane2
      expect(pane1.onDidDestroy.calls.length).toBe 1
      expect(pane2.onDidDestroy.calls.length).toBe 1

    it "shouldn't add two same panes", ->
      pane1 =
        getPath: -> 'foo/bar/index.js'
        onDidDestroy: ->
        getFileName: -> 'index.js'
        getTitle: -> 'index.js'
        id: 101

      spyOn pane1, "onDidDestroy"
      mockAtomGetView("foo/bar/index.js")

      pkgModule.addTab pane1
      pkgModule.addTab pane1
      expect(pane1.onDidDestroy.calls.length).toBe 1

     it "should add two same panes with same id, but different reference", ->
       pane1 =
         getPath: -> 'foo/bar/index.js'
         onDidDestroy: ->
         getFileName: -> 'index.js'
         getTitle: -> 'index.js'
         id: 1

       pane2 =
         getPath: -> 'foo/bar/index.js'
         onDidDestroy: ->
         getFileName: -> 'index.js'
         getTitle: -> 'index.js'
         id: 1

       spyOn pane1, "onDidDestroy"
       spyOn pane2, "onDidDestroy"
       mockAtomGetView("foo/bar/index.js")

       pkgModule.addTab pane1
       pkgModule.addTab pane2
       expect(pane1.onDidDestroy.calls.length).toBe 1
       expect(pane1.onDidDestroy.calls.length).toBe 1
