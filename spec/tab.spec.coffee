Tab = require "../lib/tab"

htmlTabMock = '<li is="tabs-tab"><div class="title">package.json</div></li>'
mochPaneInvalid =
    onDidChangePath: () ->
    getTitle: -> "notIndexFileName"
    getPath: -> "fsfsdfsf"

mochPaneValid =
    onDidChangePath: () ->
    getTitle: -> "index.js"
    getPath: -> "/Users/work/index.js"

createMochHTMLtab = ->
  item = document.createElement "div"
  item.innerHTML = htmlTabMock
  item = item.firstElementChild
  return item

describe "tab-foldername-index", ->
  it "Should init class Tab", ->
    tab = new Tab(mochPaneInvalid)
    expect(tab).toBeInstanceOf(Tab)

  it "Should work setEnabled", ->
    $element = createMochHTMLtab()

    tab = new Tab(mochPaneInvalid, $element)
    tab.setEnabled()
    # Status active
    expect(tab.disabled).toBe(false)

  it "Shound not render invalid filename", ->
    $element = createMochHTMLtab()

    tab = new Tab(mochPaneInvalid, $element)
    tab.setEnabled()
    expect($element.querySelector ".#{Tab::className}").toBeFalsy()

  it "Shound render valid filename", ->
    $element = createMochHTMLtab()

    tab = new Tab(mochPaneValid, $element)
    tab.setEnabled()
    expect($element.querySelector ".#{Tab::className}").toBeTruthy()
    expect($element.querySelector ".#{Tab::className}__original").toBeTruthy()

  it "Shound work setDisabled", ->
    $element = createMochHTMLtab()

    tab = new Tab(mochPaneValid, $element)
    tab.setEnabled()
    tab.setDisabled()
    # Status active
    expect(tab.disabled).toBe(true)
    expect($element.querySelector ".#{Tab::className}").toBeFalsy()
    expect($element.querySelector ".#{Tab::className}__original").toBeFalsy()
