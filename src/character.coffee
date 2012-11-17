{Modifiable} = require './modifiable.coffee'
{utils} = require './utils.coffee'
{Status} = require('../src/status.coffee')

class CharacterEffect extends Modifiable
  constructor: (values={}) ->
    properties =
      attack : null
      defense: null
      degree : 0
      
    super null, properties, values

class Character extends Modifiable
  constructor: (values={}) ->
    modifiable =
      initiative  : 0,
      actions     : 'full'
      isControlled: false

    properties =
      name        : "Character"
      attack      : null
      defense     : null
      stress      : 0
      stressDegree: 0
      status      : null
      effects     : {}

    super modifiable, properties, values
    @initCombat()
  
  initCombat: ->
    @stress = 0
    @actions = 'full'
    @isControlled = false
    @effects = {}
    @updateStatus()
    @initiativeValue = @rollCheck @initiative

  updateStatus: ->
    statuses = (effect.attack.statusByDegree(effect.degree).key for own k,effect of @effects)
    combined = Status.combinedStatus statuses

    @status = combined.statuses
    @statusDegree = combined.degree

    # clear the modifiers
    @clearModifiers()
    @attack?.clearModifiers()
    @defense?.clearModifiers()

    # add any modifiers
    for m in combined.modifiers
      groups = utils.makeArray m.group
      groups = ['character', 'attack', 'defense'] if 'ALL' in groups
      @addModifier(m.property, m.modifier) if 'character' in groups
      @attack?.addModifier(m.property, m.modifier) if 'attack' in groups
      @defense?.addModifier(m.property, m.modifier) if 'defense' in groups

  attack: (target) ->
    # bail if attack or defense is nil
    return if not @attack? or not target?.defense?
    target.applyHit(@attack.attack target.defense)
  
module.exports =
  Character      : Character
  CharacterEffect: CharacterEffect
