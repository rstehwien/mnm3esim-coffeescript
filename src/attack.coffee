{Modifiable} = require './modifiable.coffee'
{Status} = require('../src/status.coffee')

class AttackResult extends Modifiable
  constructor: (values={}) ->
    properties =
      attack          : null
      damage          : 0
      damageImpervious: 0
      d20             : 0
      roll            : 0
      isCrit          : false
      degree          : 1 # successful attack by default

    super null, properties, values

    # if we got an attack and values didn't have damage, default to attack.rank
    if @attack?
      @damage = @attack.rank if not values.damage?
      @damageImpervious = @attack.rank if not values.damageImpervious?

class Attack extends Modifiable
  constructor: (values={}) ->
    modifiable =
      bonus             : 10
      rank              : 10

    properties =
      penetrating       : 0
      minCrit           : 20
      isCauseStress     : true
      isPerceptionAttack: false
      isStatusRecovery  : false
      isProgressive     : false
      isMultiattack     : false
      cumulativeStatuses: ['staggered']
      statuses          : ['dazed','staggered','incapacitated']

    super modifiable, properties, values

    # TODO throw error if statuses invalid
  
  @DEFAULTS_DAMAGE = 
      bonus             : 10
      rank              : 10
      penetrating       : 0
      minCrit           : 20
      isCauseStress     : true
      isPerceptionAttack: false
      isStatusRecovery  : false
      isProgressive     : false
      isMultiattack     : false
      cumulativeStatuses: ['staggered']
      statuses          : ['dazed','staggered','incapacitated']

  @DEFAULTS_AFFLICTION = 
      bonus             : 10
      rank              : 10
      penetrating       : 0
      minCrit           : 20
      isCauseStress     : false
      isPerceptionAttack: false
      isStatusRecovery  : true
      isProgressive     : false
      isMultiattack     : false
      cumulativeStatuses: []
      statuses          : ['dazed','staggered','incapacitated']

  @createDamage: (values={}) ->
    new Attack _.extend(Attack.DEFAULTS_DAMAGE, values)
    
  @createAffliction: (values={}) ->
    new Attack _.extend(Attack.DEFAULTS_AFFLICTION, values)

  statusByResistDegree: (degree) ->
    return Status.getStatus 'normal' if degree > 0
    @statusByDegree(Math.abs degree)

  statusByDegree: (degree) ->
    return Status.getStatus 'normal' if degree < 1
    Status.getStatus @statuses[Math.min(degree, @statuses.length) - 1]
  
module.exports =
  Attack:       Attack
  AttackResult: AttackResult
