Tab = require "../lib/tab"
{expectNotExist, expectExist} = require "./tools"

pkg = require("../package.json").name
mapNames = require("../lib/mapNames")

htmlTabMock = '<li is="tabs-tab"><div class="title">package.json</div></li>'
mochPaneInvalid =
    onDidChangePath: () ->
    getTitle: -> "notIndexFileName"
    getPath: -> "path"

mochPaneValid =
    onDidChangePath: () ->
    getTitle: -> "index.js"
    getPath: -> "/Users/work/index.js"

createMochHTMLtab = ->
  item = document.createElement "div"
  item.innerHTML = htmlTabMock
  item = item.firstElementChild
  return item

$element = null

describe "tab-foldername-index", ->
  beforeEach ->
    atom.config.set('tab-foldername-index.equalsNamesEnabled', true)

  afterEach ->
    mapNames.clear()

  it "should init class Tab", ->
    $element = createMochHTMLtab()
    tab = new Tab mochPaneInvalid, [$element]
    expect(tab).toBeInstanceOf Tab

  it "should work setEnabled", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneInvalid, [$element]
    tab.setEnabled()
    # Status active
    expect(tab.disabled).toBe false

  it "shouldn't render invalid filename", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneInvalid, [$element]
    tab.setEnabled()
    expectNotExist $element.querySelector ".#{pkg}"

  it "shound render valid filename", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneValid, [$element]
    tab.setEnabled()
    expect(tab.$elements[0]).toBe $element
    expectExist $element.querySelector ".#{pkg}", $element.querySelector ".#{pkg}__original"

  it "shound render invalid two equal filenames", ->
    $element1 = createMochHTMLtab()

    tab1 = new Tab mochPaneInvalid, [$element1]
    tab1.setEnabled()

    $element2 = createMochHTMLtab()
    tab2 = new Tab mochPaneInvalid, [$element2]
    tab2.setEnabled()

    waits 20

    runs ->
      expect(tab1.$elements[0]).toBe $element1
      expectExist $element1.querySelector ".#{pkg}", $element1.querySelector ".#{pkg}__original"

      expect(tab2.$elements[0]).toBe $element2
      expectExist $element2.querySelector ".#{pkg}", $element2.querySelector ".#{pkg}__original"

  it "shoundn't render invalid two equal filenames with equalsNamesEnabled=false", ->
    atom.config.set('tab-foldername-index.equalsNamesEnabled', false)
    $element1 = createMochHTMLtab()

    tab1 = new Tab mochPaneInvalid, [$element1]
    tab1.setEnabled()

    $element2 = createMochHTMLtab()
    tab2 = new Tab mochPaneInvalid, [$element2]
    tab2.setEnabled()

    waits 20

    runs ->
      expectNotExist $element1.querySelector ".#{pkg}"
      expectNotExist $element2.querySelector ".#{pkg}"

  it "shound render index.test.js", ->
    $element = createMochHTMLtab()
    tmpMock = Object.assign {}, mochPaneValid
    tmpMock.getTitle = -> "index.test.js"
    tab = new Tab tmpMock, [$element]
    tab.setEnabled()
    expectExist $element.querySelector ".#{pkg}", $element.querySelector ".#{pkg}__original"

  it "shound render index.d.ts", ->
    $element = createMochHTMLtab()
    tmpMock = Object.assign {}, mochPaneValid
    tmpMock.getTitle = -> "index.test.js"
    tab = new Tab tmpMock, [$element]
    tab.setEnabled()
    expectExist $element.querySelector ".#{pkg}", $element.querySelector ".#{pkg}__original"

  it "should render __init__.py", ->
    $element = createMochHTMLtab()
    tmpMock = Object.assign {}, mochPaneValid
    tmpMock.getTitle = -> "__init__.py"
    tab = new Tab tmpMock, [$element]
    tab.setEnabled()
    expectExist $element.querySelector ".#{pkg}", $element.querySelector ".#{pkg}__original"

  it "should render __init__.php", ->
    $element = createMochHTMLtab()
    tmpMock = Object.assign {}, mochPaneValid
    tmpMock.getTitle = -> "__init__.php"
    tab = new Tab tmpMock, [$element]
    tab.setEnabled()
    expectExist $element.querySelector ".#{pkg}", $element.querySelector ".#{pkg}__original"

  it "shouldn't render valid filename before setEnabled", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneValid, [$element]
    expectNotExist $element.querySelector ".#{pkg}", $element.querySelector ".#{pkg}__original"

  it "should work setDisabled", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneValid, [$element]
    tab.setEnabled()
    tab.setDisabled()
    # Status active
    expect(tab.disabled).toBe true
    expectNotExist $element.querySelector ".#{pkg}", $element.querySelector ".#{pkg}__original"

  it "should clear styled tab", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneValid, [$element]
    tab.setEnabled()
    tab.clearTab()
    expectNotExist $element.querySelector ".#{pkg}", $element.querySelector ".#{pkg}__original"

  it "shouldn't run javascript in filename", ->
    $element = createMochHTMLtab()
    tmpMock = Object.assign {}, mochPaneValid
    tmpMock.getTitle = -> "<script>window.tabIndexHucked = true</script>"
    tab = new Tab tmpMock, [$element]
    tab.setEnabled()
    expect(window.tabIndexHucked).not.toBe true

  describe "onDidChangePath", ->
    callback = null
    pane = null

    beforeEach ->
      $element = createMochHTMLtab()
      pane = Object.assign {}, mochPaneValid
      pane.onDidChangePath = (fn) ->
        callback = fn

    it "should re-render if enabled", ->
      tab = new Tab pane, [$element]
      tab.setEnabled()
      pane.getTitle = -> "index.py"
      pane.getPath = -> "/Users/home/index.py"
      callback()

      waits 20

      runs ->
        expect($element.querySelector(".#{pkg}__file").textContent).toBe "index.py"
        expect($element.querySelector(".#{pkg}__folder").textContent).toBe "home"

    it "shouldn't re-render if disabled", ->
      tab = new Tab(pane, [$element])
      tab.setEnabled()
      pane.getTitle = -> "index.py"
      pane.getPath = -> "/Users/home/index.py"
      tab.setDisabled()
      callback()

      waits 20

      runs ->
        expect(tab.disabled).toBe true
        expectNotExist $element.querySelector ".#{pkg}", $element.querySelector ".#{pkg}__original"

    it "shound render invalid two equal filenames after rename one", ->
      callback1 = null
      pane1 = Object.assign {}, mochPaneInvalid
      pane1.getTitle = -> "invalid1"
      pane1.getPath = -> "/Users/home/invalid1"
      pane1.onDidChangePath = (fn) ->
        callback1 = fn
      $element1 = createMochHTMLtab()

      tab1 = new Tab pane1, [$element1]
      tab1.setEnabled()

      callback2 = null
      pane2 = Object.assign {}, mochPaneInvalid
      pane2.getTitle = -> "invalid2"
      pane2.getPath = -> "/Users/home/invalid2"
      pane2.onDidChangePath = (fn) ->
        callback2 = fn
      $element2 = createMochHTMLtab()
      tab2 = new Tab pane2, [$element2]
      tab2.setEnabled()

      # Different names yet. So should'n render
      expectNotExist $element1.querySelector ".#{pkg}"
      expectNotExist $element2.querySelector ".#{pkg}"

      # Let's rename the second tab like first tab
      pane2.getTitle = -> "invalid1"
      pane2.getPath = -> "/Users/home/invalid1"
      callback2()

      waits 20

      runs ->
        expect(tab1.$elements[0]).toBe $element1
        expectExist $element1.querySelector ".#{pkg}", $element1.querySelector ".#{pkg}__original"

        expect(tab2.$elements[0]).toBe $element2
        expectExist $element2.querySelector ".#{pkg}", $element2.querySelector ".#{pkg}__original"

    it "shoundn't render invalid two equal filenames after rename one with equalsNamesEnabled=false", ->
      callback1 = null
      pane1 = Object.assign {}, mochPaneInvalid
      pane1.getTitle = -> "invalid1"
      pane1.getPath = -> "/Users/home/invalid1"
      pane1.onDidChangePath = (fn) ->
        callback1 = fn
      $element1 = createMochHTMLtab()

      tab1 = new Tab pane1, [$element1]
      tab1.setEnabled()

      callback2 = null
      pane2 = Object.assign {}, mochPaneInvalid
      pane2.getTitle = -> "invalid2"
      pane2.getPath = -> "/Users/home/invalid2"
      pane2.onDidChangePath = (fn) ->
        callback2 = fn
      $element2 = createMochHTMLtab()
      tab2 = new Tab pane2, [$element2]
      tab2.setEnabled()

      # Different names yet. So should'n render
      expectNotExist $element1.querySelector ".#{pkg}"
      expectNotExist $element2.querySelector ".#{pkg}"

      # Let's rename the second tab like first tab
      pane2.getTitle = -> "invalid1"
      pane2.getPath = -> "/Users/home/invalid1"

      atom.config.set('tab-foldername-index.equalsNamesEnabled', false)
      callback2()

      waits 20

      runs ->
        expectNotExist $element1.querySelector ".#{pkg}"
        expectNotExist $element2.querySelector ".#{pkg}"


  it "should create Tab without onDidChangePath, but with file", ->
    moch =
      file:
          onDidRename: () ->
      getTitle: -> "notIndexFileName"
      getPath: -> "path"

    tab = new Tab mochPaneInvalid
    expect(tab).toBeInstanceOf Tab
