_ = require 'underscore'

class Modifiable
    constructor:  (data) ->
      @_modifiers = {}
      for own k, v of data
        do (k, v) =>
          @["_#{k}"] = v
          Object.defineProperty @, k,
            get: -> @_applyModifiers(k, @["_#{k}"])           
            set: (v) -> @["_#{k}"] = v
            enumerable: true
            configurable: true

    _applyModifiers: (k, v) =>
      modifiers = []
      Array::push.apply modifiers, @_modifiers[k] if  @_modifiers[k]?
      Array::push.apply modifiers, @_modifiers['ALL'] if  @_modifiers['ALL']?

      for m in modifiers
        v = m.call(this, v)
      v

    addModifier: (k, m) ->
      @_modifiers[k] ?= []
      @_modifiers[k].push m

    clearAllModifiers: -> @_modifiers = {}

    clearModifiers: (k) -> @_modifiers[k] = []


module.exports =
  Modifiable: Modifiable
