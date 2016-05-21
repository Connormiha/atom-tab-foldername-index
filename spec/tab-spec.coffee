Tab = require "../lib/tab"
{expectNotExist, expectExist} = require "./tools"

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
  it "should init class Tab", ->
    tab = new Tab mochPaneInvalid
    expect(tab).toBeInstanceOf Tab

  it "should work setEnabled", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneInvalid, $element
    tab.setEnabled()
    # Status active
    expect(tab.disabled).toBe false

  it "shouldn't render invalid filename", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneInvalid, $element
    tab.setEnabled()
    expectNotExist $element.querySelector ".#{Tab::className}"

  it "shound render valid filename", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneValid, $element
    tab.setEnabled()
    expectExist $element.querySelector ".#{Tab::className}", $element.querySelector ".#{Tab::className}__original"

  it "shound render index.test.js", ->
    $element = createMochHTMLtab()
    tmpMock = Object.assign {}, mochPaneValid
    tmpMock.getTitle = -> "index.test.js"
    tab = new Tab tmpMock, $element
    tab.setEnabled()
    expectExist $element.querySelector ".#{Tab::className}", $element.querySelector ".#{Tab::className}__original"

  it "shoundn't render index.foo.js", ->
    $element = createMochHTMLtab()
    tmpMock = Object.assign {}, mochPaneValid
    tmpMock.getTitle = -> "index.foo.js"
    tab = new Tab tmpMock, $element
    tab.setEnabled()
    expectNotExist $element.querySelector ".#{Tab::className}", $element.querySelector ".#{Tab::className}__original"

  it "should render __init__.py", ->
    $element = createMochHTMLtab()
    tmpMock = Object.assign {}, mochPaneValid
    tmpMock.getTitle = -> "__init__.py"
    tab = new Tab tmpMock, $element
    tab.setEnabled()
    expectExist $element.querySelector ".#{Tab::className}", $element.querySelector ".#{Tab::className}__original"

  it "should render __init__.php", ->
    $element = createMochHTMLtab()
    tmpMock = Object.assign {}, mochPaneValid
    tmpMock.getTitle = -> "__init__.php"
    tab = new Tab tmpMock, $element
    tab.setEnabled()
    expectExist $element.querySelector ".#{Tab::className}", $element.querySelector ".#{Tab::className}__original"

  it "shouldn't render valid filename before setEnabled", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneValid, $element
    expectNotExist $element.querySelector ".#{Tab::className}", $element.querySelector ".#{Tab::className}__original"

  it "should work setDisabled", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneValid, $element
    tab.setEnabled()
    tab.setDisabled()
    # Status active
    expect(tab.disabled).toBe true
    expectNotExist $element.querySelector ".#{Tab::className}", $element.querySelector ".#{Tab::className}__original"

  it "should clear styled tab", ->
    $element = createMochHTMLtab()

    tab = new Tab mochPaneValid, $element
    tab.setEnabled()
    tab.clearTab()
    expectNotExist $element.querySelector ".#{Tab::className}", $element.querySelector ".#{Tab::className}__original"

  it "shouldn't run javascript in filename", ->
    $element = createMochHTMLtab()
    tmpMock = Object.assign {}, mochPaneValid
    tmpMock.getTitle = -> "<script>window.tabIndexHucked = true</script>"
    tab = new Tab tmpMock, $element
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
      tab = new Tab pane, $element
      tab.setEnabled()
      pane.getTitle = -> "index.py"
      pane.getPath = -> "/Users/home/index.py"
      callback()

      waits 20

      runs ->
        expect($element.querySelector(".#{Tab::className}__file").textContent).toBe "index.py"
        expect($element.querySelector(".#{Tab::className}__folder").textContent).toBe "home"

    it "shouldn't re-render if disabled", ->
      tab = new Tab(pane, $element)
      tab.setEnabled()
      pane.getTitle = -> "index.py"
      pane.getPath = -> "/Users/home/index.py"
      tab.setDisabled()
      callback()

      waits 20

      runs ->
        expect(tab.disabled).toBe true
        expectNotExist $element.querySelector ".#{Tab::className}", $element.querySelector ".#{Tab::className}__original"
