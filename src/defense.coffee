{Modifiable} = require './modifiable.coffee'

class ResistResult
  constructor: (@defense, @d20, @roll, @degree, @stress, @status) ->

class Defense extends Modifiable
  constructor: (values) ->
    modifiable =
      value:      10
      save:       10
      impervious: null # any attack difficulty less is ignored

    super modifiable, null, values

  resistHit: (hit, stress) ->
    resist = new ResistResult this, null, null, 4, 0, null

    # bail if impervious to this attack
    return resist if @impervious? and (@impervious - hit.attack.penetrating) >= hit.damageImpervious
    ###
      # Always roll vs Damage+10 to determin status and stress
      # The degree will be the status inflicted
      # Stress caused if degree <= 1 (equivalent to Damage+15)
      resist.d20 = roll_d20
      resist.roll = resist.d20 + self.save - stress
      resist.degree = check_degree(hit.damage + 10, resist.roll)

      if resist.d20 == 20 then
        resist.degree = resist.degree < 1 ? 1 : resist.degree + 1
      end

      # if stress is caused, it is for a status effect of -1 and higher (equivalent to save of rank+15)
      resist.stress = 1 if hit.attack.is_cause_stress and resist.degree <= 1

      resist.status = hit.attack.status_by_resist_degree(resist.degree)

      return resist
    ###
  
module.exports =
  Defense:      Defense
  ResistResult: ResistResult
