{CompositeDisposable} = require "atom"
Tab = require "./tab"

realTimeout = window.setTimeout

module.exports = TabFoldernameIndex =

  activate: (state) ->
    @active = if "active" of state then state.active else true

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'tab-foldername-index:toggle': => @toggle()

    @tabs = {}

    if atom.packages.isPackageActive "tabs"
      @init()
    else
      onceActivated = atom.packages.onDidActivatePackage ({name}) =>
        if name == "tabs"
          onceActivated.dispose()
          @init()

  init: ->
    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.onDidAddPaneItem ({item}) =>
      realTimeout(() => @addTab(item))

    panes = atom.workspace.getPaneItems()
    for item in panes
      @addTab item

  deferParse: ->
    setTimeout => @parceTabs()

  ###*
   * [addTab description]
   * @param {Panel}
  ###
  addTab: (pane) ->
    path = pane.getPath?()
    return unless path

    return if @tabs[pane.id]

    cssPath = path.replace(/\\/g, "\\\\").replace(/\"/g, "\\\"")
    item = atom.views.getView(atom.workspace).querySelector ".tab .title[data-path=\"#{cssPath}\"]"

    return unless item

    @tabs[pane.id] = new Tab(pane, item.parentNode)
    removeDispose = pane.onDidDestroy () =>
      removeDispose.dispose()
      @handleTabRemove pane.id

    @subscriptions.add removeDispose
    @tabs[pane.id].setEnabled() if @active

  ###*
   * Runs when close tab or destroed package
   * @param  {Number} id
  ###
  handleTabRemove: (id) ->
    return unless @tabs[id]
    @tabs[id].destroy()
    delete @tabs[id]

  deactivate: ->
    @setDisabled()
    for id in Object.keys @tabs
      @handleTabRemove id

    @subscriptions.dispose()

  serialize: ->
    active: @active

  setEnabled: ->
    for key, tab of @tabs
      continue unless @tabs.hasOwnProperty key
      tab.setEnabled()

    return

  setDisabled: ->
    for key, tab of @tabs
      continue unless @tabs.hasOwnProperty key
      tab.setDisabled()

    return

  toggle: ->
    @active = !@active

    if @active
      @setEnabled()
    else
      @setDisabled()
