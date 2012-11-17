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
      degree          : -1 # failed attack by default

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

  attack: (defense) ->
    # create basic miss
    hit = new AttackResult {attack: this, degree: -1}

    # if perception attack; return a basic hit
    if @isPerceptionAttack
      hit.degree = 1
      return hit

    hit.d20 = @rollCheck()
    hit.roll = hit.d20 + @bonus

    # roll of 1 automatically misses
    return hit if hit.d20 is 1

    hit.degree = @checkDegree(defense.value+10, hit.roll)

    # crit if you hit and got the min_crit or better
    hit.isCrit = (hit.degree > 0 and hit.d20 >= @minCrit)

    # guaranteed hit if you rolled a 20
    hit.degree = 1 if (hit.d20 is 20 and hit.degree < 1)

    # if hit degree < 0 we have missed
    return hit if hit.degree < 0

    # crit bumps the damage and impervious up by 5
    if hit.isCrit
      hit.damage += 5
      hit.damageImpervious += 5

    # multi-attack bumps up by 5 or 2 but not damage_impervious
    if @isMultiattack and hit.degree > 1
      hit.damage += (if hit.degree >= 3 then 5 else 2)

    return hit
  
module.exports =
  Attack:       Attack
  AttackResult: AttackResult
