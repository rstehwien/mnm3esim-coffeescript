{Modifiable} = require './modifiable.coffee'

class AttackResult
  constructor: (@attack, @damage, @damageImpervious, @d20, @roll, @isCrit, @degree) ->

class Attack extends Modifiable
  constructor: (values) ->
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
  
  
module.exports =
  Attack:       Attack
  AttackResult: AttackResult
