{CompositeDisposable} = require "atom"
Tab = require "./tab"

realTimeout = window.setTimeout

module.exports =
  activate: ({active}) ->
    @active = active != false

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add "atom-workspace", "tab-foldername-index:toggle": => @toggle()

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

    @tabs[pane.id] = new Tab pane, item.parentNode
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
    for key in Object.keys @tabs
      @tabs[key].setEnabled()

    return

  setDisabled: ->
    for key in Object.keys @tabs
      @tabs[key].setDisabled()

    return

  toggle: ->
    @active = !@active

    if @active
      @setEnabled()
    else
      @setDisabled()
