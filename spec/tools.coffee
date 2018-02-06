{JSDOM} = require('jsdom')
dom = new JSDOM("<body></body>")
originalAtomViewsGetView = atom.views.getView

module.exports =
  expectNotExist: ->
    for $item in arguments
      expect($item).not.toExist()

  expectExist: ->
    for $item in arguments
      expect($item).toExist()

  mockAtomGetView: (cssPath) ->
    atom.views.getView = ->
      div = dom.window.document.createElement "div"
      div.innerHTML = "
         <div class=\"tab\">
            <div class=\"title\" data-path=\"#{cssPath}\">
            </div>
         </div>
        "
      return div

  restoreAtomGetView: ->
    atom.views.getView = originalAtomViewsGetView
