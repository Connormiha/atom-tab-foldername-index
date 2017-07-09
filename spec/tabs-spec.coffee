Tabs = require "../lib/main"
{expectNotExist, expectExist} = require "./tools"
pkg = require("../package.json").name

describe "tab-foldername-index module", ->
  pkgModule = null

  beforeEach ->
    atom.config.set("#{pkg}.equalsNamesEnabled", true)
    pkgModule = Object.assign {}, Tabs
    delete pkgModule.active
    delete pkgModule.tabs
    delete pkgModule.subscriptions

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
    pane = null

    beforeEach ->
      pane =
        getPath: -> 'foo/bar/index.js'
        onDidDestroy: ->

    it "shouldn't fail with pane without getPath", ->
      pkgModule.activate({})
      expect(-> pkgModule.addTab({})).not.toThrow();

    it "shouldn't fail with pane with empty path", ->
      pkgModule.activate({})
      expect(-> pkgModule.addTab({getPath: -> ""})).not.toThrow();
