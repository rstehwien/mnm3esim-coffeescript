_ = require 'underscore'

class Modifiable
    constructor:  (data) ->
      for own k, v of data
        do (k, v) =>
          @["_#{k}"] = v
          Object.defineProperty @, k,
            get: -> @["_#{k}"]
            set: (v) -> @["_#{k}"] = v
            enumerable: true
            configurable: true


module.exports =
  Modifiable: Modifiable
