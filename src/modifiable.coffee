{utils} = require './utils.coffee'

class Modifiable
    constructor:  (modifiable, properties, values) ->
      @_modifiers = {}
      @_modifiable modifiable
      @_properties properties
      @_values values

    _modifiable: (obj) ->
      if obj? then for own k, v of obj
        do (k, v) =>
          @["_#{k}"] = v
          Object.defineProperty @, k,
            get: -> @_applyModifiers k, @["_#{k}"]         
            set: (v) -> @["_#{k}"] = v
            enumerable: true
            configurable: true

    _properties: (obj) ->
      if obj? then for own k, v of obj
        do (k, v) =>
          @[k] = v

    _values: (obj) ->
      if obj? then for own k, v of obj
        do (k, v) =>
          throw new Error "Invalid property \'#{k}\'" if not Object::hasOwnProperty.call(this, k)
          @[k] = v

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

    clearModifiers: (k) -> 
      if k?
        @_modifiers[k] = []
      else
        @clearModifiers(key) for own key, value of @_modifiers

    rollCheck: (bonus=0) =>
      @_applyModifiers 'rollCheck', utils.rollD20(bonus)

    checkDegree: (difficulty, check) ->
      utils.checkDegree difficulty, check


module.exports =
  Modifiable: Modifiable
