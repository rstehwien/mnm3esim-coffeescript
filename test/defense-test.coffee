{Defense, ResistResult} = require('../src/defense.coffee')
{Attack, AttackResult} = require('../src/attack.coffee')

describe "Defense", ->

  beforeEach () ->
    @defense = new Defense
    @attack = Attack.createDamage()
    @hit = new AttackResult {attack: @attack}

  it "Should have defaults", ->
    expect(@defense.value).to.be.equal 10
    expect(@defense.save).to.be.equal 10
    expect(@defense.impervious).to.be.null

  it "Should have bounce if impervious", ->
    @defense.addModifier 'rollCheck', (x) -> 1 #worst roll for defense
    @defense.impervious = @attack.rank
    resist = @defense.resistHit @hit, 0
    expect(resist.degree).to.be.equal 4

  it "Should totally save on a roll of 15", ->
    @defense.addModifier 'rollCheck', (x) -> 15
    resist = @defense.resistHit @hit, 0
    expect(resist.d20).to.be.equal 15
    expect(resist.roll).to.be.equal 25
    expect(resist.degree).to.be.equal 2
    expect(resist.stress).to.be.equal 0
    expect(resist.status.key).to.be.equal 'normal'

  it "Should totally save and bump success degree up on a roll of 20", ->
    @defense.addModifier 'rollCheck', (x) -> 20
    resist = @defense.resistHit @hit, 0
    expect(resist.d20).to.be.equal 20
    expect(resist.roll).to.be.equal 30
    expect(resist.degree).to.be.equal 4
    expect(resist.stress).to.be.equal 0
    expect(resist.status.key).to.be.equal 'normal'

  it "Should take one stress on a roll of 10", ->
    @defense.addModifier 'rollCheck', (x) -> 10
    resist = @defense.resistHit @hit, 0
    expect(resist.d20).to.be.equal 10
    expect(resist.roll).to.be.equal 20
    expect(resist.degree).to.be.equal 1
    expect(resist.stress).to.be.equal 1
    expect(resist.status.key).to.be.equal 'normal'

  it "Should take first degree and one stress on a roll of 5", ->
    @defense.addModifier 'rollCheck', (x) -> 5
    resist = @defense.resistHit @hit, 0
    expect(resist.d20).to.be.equal 5
    expect(resist.roll).to.be.equal 15
    expect(resist.degree).to.be.equal -1
    expect(resist.stress).to.be.equal 1
    expect(resist.status.key).to.be.equal 'dazed'

  it "Should take second degree and one stress on a roll of 1", ->
    @defense.addModifier 'rollCheck', (x) -> 1
    resist = @defense.resistHit @hit, 0
    expect(resist.d20).to.be.equal 1
    expect(resist.roll).to.be.equal 11
    expect(resist.degree).to.be.equal -2
    expect(resist.stress).to.be.equal 1
    expect(resist.status.key).to.be.equal 'staggered'

  it "Should take third degree and one stress on a roll of 1 plus 2 stress", ->
    @defense.addModifier 'rollCheck', (x) -> 1
    resist = @defense.resistHit @hit, 2
    expect(resist.d20).to.be.equal 1
    expect(resist.roll).to.be.equal 9
    expect(resist.degree).to.be.equal -3
    expect(resist.stress).to.be.equal 1
    expect(resist.status.key).to.be.equal 'incapacitated'

  it "Should roll of 20 bumps degree up to only take staggered", ->
    @defense.addModifier 'rollCheck', (x) -> 20
    resist = @defense.resistHit @hit, 25
    expect(resist.d20).to.be.equal 20
    expect(resist.roll).to.be.equal 5
    expect(resist.degree).to.be.equal -2
    expect(resist.stress).to.be.equal 1
    expect(resist.status.key).to.be.equal 'staggered'


  it "Should roll of 19 has enough stress to 'incapacitated'", ->
    @defense.addModifier 'rollCheck', (x) -> 19
    resist = @defense.resistHit @hit, 24
    expect(resist.d20).to.be.equal 19
    expect(resist.roll).to.be.equal 5
    expect(resist.degree).to.be.equal -3
    expect(resist.stress).to.be.equal 1
    expect(resist.status.key).to.be.equal 'incapacitated'

  it "Should take no damage with invulnerable 10, penetrating 5, roll 10", ->
    @attack.penetrating = 5
 
    @defense.addModifier 'rollCheck', (x) -> 10
    @defense.impervious = @attack.rank
 
    resist = @defense.resistHit @hit, 0
    expect(resist.d20).to.be.equal 10
    expect(resist.roll).to.be.equal 20
    expect(resist.degree).to.be.equal 2
    expect(resist.stress).to.be.equal 0
    expect(resist.status.key).to.be.equal 'normal'


  it "Should take one stress with invulnerable 10, penetrating 15, roll 10", ->
    @attack.penetrating = 15

    @defense.addModifier 'rollCheck', (x) -> 10
    @defense.impervious = @attack.rank
    resist = @defense.resistHit @hit, 0
    expect(resist.d20).to.be.equal 10
    expect(resist.roll).to.be.equal 20
    expect(resist.degree).to.be.equal 1
    expect(resist.stress).to.be.equal 1
    expect(resist.status.key).to.be.equal 'normal'
