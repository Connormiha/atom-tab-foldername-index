module.exports =
  expectNotExist: ->
    for $item in arguments
      expect($item).not.toExist()

  expectExist: ->
    for $item in arguments
      expect($item).toExist()
