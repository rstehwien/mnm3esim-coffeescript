{Modifiable} = require './modifiable.coffee'
{utils} = require './utils.coffee'

class ResistResult extends Modifiable
  constructor: (values={}) ->
    properties =
      defense: null
      d20    : 0
      roll   : 0
      degree : 4 #successful resistance by default
      stress : 0
      status : 'normal'
      
    super null, properties, values

class Defense extends Modifiable
  constructor: (values={}) ->
    modifiable =
      value     : 10
      save      : 10
      impervious: null # any attack difficulty less is ignored

    super modifiable, null, values

  resistHit: (hit, stress) ->
    resist = new ResistResult {defense: this}
    # return completely successful resist if missed
    return resist if hit.degree < 1

    damage = hit.damage

    # if impervious to attack's damage, then damage is equal to penetrating
    if @impervious? and @impervious >= hit.damageImpervious
      return resist if not hit.attack.penetrating? or hit.attack.penetrating < 1
      damage = Math.min(hit.attack.penetrating, hit.damage)

    # Always roll vs Damage+10 to determin status and stress
    # The degree will be the status inflicted
    # Stress caused if degree <= 1 (equivalent to Damage+15)
    resist.d20 = @rollCheck()
    resist.roll = resist.d20 + @save - stress
    resist.degree = @checkDegree(damage + 10, resist.roll)

    # critical success bumps up degree by one
    resist.degree = utils.increaseDegree resist.degree if resist.d20 is 20

    # if stress is caused, it is for a status effect of -1 and higher (equivalent to save of rank+15)
    resist.stress = 1 if hit.attack.isCauseStress and resist.degree <= 1

    resist.status = hit.attack.statusByResistDegree(resist.degree)

    return resist
  
module.exports =
  Defense:      Defense
  ResistResult: ResistResult
