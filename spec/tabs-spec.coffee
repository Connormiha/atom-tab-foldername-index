Tabs = require "../lib/main"
{expectNotExist, expectExist} = require "./tools"

describe "tab-foldername-index module", ->
  pkgModule = null

  beforeEach ->
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
