{Attack, AttackResult} = require('../src/attack.coffee')
{Defense} = require('../src/defense.coffee')

describe "AttackResult", ->
  it "Should fill in damage when given attack", ->
    hit = new AttackResult {attack: Attack.createDamage({rank: 11})}
    expect(hit.damage).to.be.equal hit.attack.rank
    expect(hit.damageImpervious).to.be.equal hit.attack.rank

  it "Should allow overriding damage", ->
    hit = new AttackResult {attack: Attack.createDamage(), damage:100, damageImpervious: 150}
    expect(hit.damage).to.be.equal 100
    expect(hit.damageImpervious).to.be.equal 150

describe "Attack", ->

  beforeEach ->
    @defense = new Defense
    @attack = Attack.createDamage()
 
  it "Should have defaults", ->
    expect(@attack.bonus).to.be.equal 10
    expect(@attack.rank).to.be.equal 10
    expect(@attack.penetrating).to.be.equal 0
    expect(@attack.minCrit).to.be.equal 20
    expect(@attack.isCauseStress).to.be.true
    expect(@attack.isPerceptionAttack).to.be.false
    expect(@attack.isStatusRecovery).to.be.false
    expect(@attack.isProgressive).to.be.false
    expect(@attack.isMultiattack).to.be.false
    expect(@attack.cumulativeStatuses).to.be.equivalentArray ['staggered']
    expect(@attack.statuses).to.be.equivalentArray ['dazed','staggered','incapacitated']

  it "Should hit automatically if perception attack", ->
    @attack.isPerceptionAttack = true
    @attack.addModifier 'rollCheck', (x) -> -100 # no way this could hit, make sure never rolled
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 1
    expect(hit.damage).to.be.equal @attack.rank
    expect(hit.damageImpervious).to.be.equal @attack.rank
    expect(hit.d20).to.be.equal 0
    expect(hit.roll).to.be.equal 0
    expect(hit.isCrit).to.be.equal false

  it "Should get a basic hit if roll a 10", ->
    @attack.addModifier 'rollCheck', (x) -> 10
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 1
    expect(hit.damage).to.be.equal @attack.rank
    expect(hit.damageImpervious).to.be.equal @attack.rank
    expect(hit.d20).to.be.equal 10
    expect(hit.roll).to.be.equal 20
    expect(hit.isCrit).to.be.equal false

  it "Should miss if roll a 9", ->
    @attack.addModifier 'rollCheck', (x) -> 9
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal -1
    expect(hit.damage).to.be.equal @attack.rank
    expect(hit.damageImpervious).to.be.equal @attack.rank
    expect(hit.d20).to.be.equal 9
    expect(hit.roll).to.be.equal 19
    expect(hit.isCrit).to.be.equal false

  it "Should get a crit if roll a 20", ->
    @attack.addModifier 'rollCheck', (x) -> 20
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 3
    expect(hit.damage).to.be.equal (@attack.rank+5)
    expect(hit.damageImpervious).to.be.equal (@attack.rank+5)
    expect(hit.d20).to.be.equal 20
    expect(hit.roll).to.be.equal 30
    expect(hit.isCrit).to.be.equal true

  it "Should get a crit if roll a 15 and minCrit is 15", ->
    @attack.addModifier 'rollCheck', (x) -> 15
    @attack.minCrit = 15
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 2
    expect(hit.damage).to.be.equal (@attack.rank+5)
    expect(hit.damageImpervious).to.be.equal (@attack.rank+5)
    expect(hit.d20).to.be.equal 15
    expect(hit.roll).to.be.equal 25
    expect(hit.isCrit).to.be.equal true

  it "Should not get a crit if roll a 20 and wouldn't hit... just a hit", ->
    @attack.addModifier 'rollCheck', (x) -> 20
    @defense.value = @attack.bonus + 11
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 1
    expect(hit.damage).to.be.equal @attack.rank
    expect(hit.damageImpervious).to.be.equal @attack.rank
    expect(hit.d20).to.be.equal 20
    expect(hit.roll).to.be.equal 30
    expect(hit.isCrit).to.be.equal false

  it "Should increase damage by 0 for multiattack degree 1", ->
    @attack.addModifier 'rollCheck', (x) -> 10
    @attack.isMultiattack = true
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 1
    expect(hit.damage).to.be.equal @attack.rank
    expect(hit.damageImpervious).to.be.equal @attack.rank
    expect(hit.d20).to.be.equal 10
    expect(hit.roll).to.be.equal 20
    expect(hit.isCrit).to.be.equal false

  it "Should increase damage by 2 for multiattack degree 2", ->
    @attack.addModifier 'rollCheck', (x) -> 15
    @attack.isMultiattack = true
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 2
    expect(hit.damage).to.be.equal (@attack.rank + 2)
    expect(hit.damageImpervious).to.be.equal @attack.rank
    expect(hit.d20).to.be.equal 15
    expect(hit.roll).to.be.equal 25
    expect(hit.isCrit).to.be.equal false

  it "Should increase damage by 5 for multiattack degree 3", ->
    @attack.addModifier 'rollCheck', (x) -> 19
    @attack.isMultiattack = true
    @defense.value = 9
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 3
    expect(hit.damage).to.be.equal (@attack.rank + 5)
    expect(hit.damageImpervious).to.be.equal @attack.rank
    expect(hit.d20).to.be.equal 19
    expect(hit.roll).to.be.equal 29
    expect(hit.isCrit).to.be.equal false

  it "Should increase damage by 5 for multiattack degree >3", ->
    @attack.addModifier 'rollCheck', (x) -> 19
    @attack.isMultiattack = true
    @defense.value = 1
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 4
    expect(hit.damage).to.be.equal (@attack.rank + 5)
    expect(hit.damageImpervious).to.be.equal @attack.rank
    expect(hit.d20).to.be.equal 19
    expect(hit.roll).to.be.equal 29
    expect(hit.isCrit).to.be.equal false

  it "Should increase damage by 10 for crit plus multiattack degree 3", ->
    @attack.addModifier 'rollCheck', (x) -> 20
    @attack.isMultiattack = true
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 3
    expect(hit.damage).to.be.equal (@attack.rank + 10)
    expect(hit.damageImpervious).to.be.equal (@attack.rank + 5)
    expect(hit.d20).to.be.equal 20
    expect(hit.roll).to.be.equal 30
    expect(hit.isCrit).to.be.equal true


  it "Should increase damage by 7 for crit plus multiattack degree 2", ->
    @attack.addModifier 'rollCheck', (x) -> 20
    @attack.isMultiattack = true
    @defense.value = 15
    
    hit = @attack.attack @defense
    expect(hit.degree).to.be.equal 2
    expect(hit.damage).to.be.equal (@attack.rank + 7)
    expect(hit.damageImpervious).to.be.equal (@attack.rank + 5)
    expect(hit.d20).to.be.equal 20
    expect(hit.roll).to.be.equal 30
    expect(hit.isCrit).to.be.equal true
