{Modifiable} = require './modifiable.coffee'
{utils} = require './utils.coffee'
{Status} = require('../src/status.coffee')

class CharacterEffect extends Modifiable
  constructor: (values={}) ->
    properties =
      attack : null
      defense: null
      status : null
      degree : null

    super null, properties, values

    # default degree and status if not given and was given what needed
    @degree = values.status.degree if (not values.degree?) and values.status?
    @status = values.attack.statusByDegree values.degree if (not values.status?) and values.attack? and values.degree?

class Character extends Modifiable
  constructor: (values={}) ->
    modifiable =
      initiative  : 0,
      actions     : 'full'
      isControlled: false
      speed       : 0

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
    # clear any normal status effects
    delete @effects[uid] for uid in (k for own k, v of @effects when v.status.degree < 1)

    statuses = (effect.status.key for own k,effect of @effects)
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
    # bail if attack or defense is null
    return if not @attack? or not target?.defense?
    target.applyHit(@attack.attack target.defense)
  
  applyHit: (hit) ->
    # bail if missed
    return if hit.degree < 0

    resist = @defense.resistHit hit, @stress
    @stress += resist.stress

    # bail if we took no status
    return if not resist.status? or resist.status.degree < 1

    curStatus = if @effects[hit.attack.uid]? then @effects[hit.attack.uid].status else Status.getStatus 'normal'
    newStatus = resist.status

    #TODO when dealing with multiple attacks need to handle cumulative to compare against  overall status
    
    # cumulative attacks add their degrees
    # NOTE: damage sets the cumulative degree to ['staggered'] which means another staggered will add 2 to the degree, but it works out right
    cumulativeStatuses = hit.attack.cumulativeStatuses
    if curStatus.key in cumulativeStatuses and newStatus.key in cumulativeStatuses
      newStatus = hit.attack.statusByDegree(curStatus.degree + newStatus.degree)

    # non-cumulative only replaces if new degree is better
    if newStatus.degree > curStatus.degree 
      @addEffect(new CharacterEffect {attack: hit.attack, defense: resist.defense, status: newStatus})

  addEffect: (effect) ->
    @effects[effect.attack.uid] = effect
    @updateStatus()

  endRoundRecovery: ->
    changed = false
    for own k, effect of @effects
      # next if no recovery check allowed or needed
      continue if not effect.attack.isStatusRecovery or effect.status.degree < 1 or effect.status.degree > 2

      resistance = @checkDegree (effect.attack.rank + 10), (@rollCheck effect.defense.save)

      # if resistance sucessful, lower the status by one
      if resistance > 0
        changed = true
        effect.status = Status.getStatus 'normal'

      # if failed and progressive, increase status by one
      else if effect.attack.isProgressive
        changed = true
        effect.status = effect.attack.statusByDegree(effect.status.degree + 1)

    if changed
      @updateStatus
  
module.exports =
  Character      : Character
  CharacterEffect: CharacterEffect
