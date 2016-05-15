{CompositeDisposable} = require "atom"
Tab = require "./tab"

module.exports = WordCount22 =
  active: true

  activate: (state) ->
    @active = state.active
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'tab-foldername-index:toggle': => @toggle()

    @tabs = {}

    if atom.packages.isPackageActive("tabs")
      @init()
    else
      @onceActivated = atom.packages.onDidActivatePackage (p) =>
        if p.name == "tabs"
          @onceActivated.dispose()
          @init()

  init: ->
    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.onDidAddPaneItem (event) =>
      if typeof event.item.getTitle == "function"
        setTimeout(() => @addTab(event.item))

    # @disposables.add atom.workspace.onDidDestroyPane (event) =>
    #   id = event.item.id
    #   @handleTabRemove id

    panes = atom.workspace.getPaneItems()
    for item in panes
      @addTab(item)

  deferParse: ->
    setTimeout => @parceTabs()

  addTab: (pane) ->
    path = pane.getPath?()
    return unless path

    cssPath = path.replace(/\\/g, "\\\\").replace(/\"/g, "\\\"")
    item = atom.views.getView(atom.workspace).querySelector ".tab .title[data-path=\"#{cssPath}\"]"

    return unless item

    @tabs[pane.id] = new Tab(pane, item.parentNode)
    removeDispose = pane.onDidDestroy () =>
      removeDispose.dispose()
      @handleTabRemove pane.id

    @tabs[pane.id].setEnabled() if @active

  handleTabRemove: (id) ->
    @tabs[id].destroy()
    delete @tabs[id]

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @wordCount22View.destroy()

  serialize: ->
    active: @active

  setEnabled: ->
    for key, tab of @tabs
      continue unless @tabs.hasOwnProperty key
      tab.setEnabled()

  setDisabled: ->
    for key, tab of @tabs
      continue unless @tabs.hasOwnProperty key
      tab.setDisabled()

  toggle: ->
    @active = !@active

    if @active
      @setEnabled()
    else
      @setDisabled()
