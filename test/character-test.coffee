{Character, CharacterEffect} = require('../src/character.coffee')
{Status, StatusModifier} = require('../src/status.coffee')
{Attack, AttackResult} = require('../src/attack.coffee')
{Defense, ResistResult} = require('../src/defense.coffee')
_ = require 'underscore'

describe "CharacterEffect", ->
  beforeEach ->
    @attack = Attack.createDamage()
    @defense = new Defense

  it "Should fill in degree when given status", ->
    effect = new CharacterEffect {attack: @attack, defense: @defense, status: (@attack.statusByDegree 1)}
    expect(effect.status.key).to.be.equal 'dazed'
    expect(effect.degree).to.be.equal 1

  it "Should fill in status when given degree", ->
    effect = new CharacterEffect {attack: @attack, defense: @defense, degree: 3}
    expect(effect.status.key).to.be.equal 'incapacitated'
    expect(effect.degree).to.be.equal 3

describe "Character", ->

  beforeEach ->
    @attackDamage = Attack.createDamage()
    @attackAffliction = Attack.createAffliction()
    @character = new Character {attack: @attackDamage, defense: new Defense}
    @hit = new AttackResult {attack: @attackDamage, d20: 15, roll: 25, isCrit: false, degree: 1}

  it "Should have defaults", ->
    c = new Character
    expect(c.name).to.be.equal 'Character'
    expect(c.initiative).to.be.equal 0
    expect(c.actions).to.be.equal 'full'
    expect(c.isControlled).to.be.false
    expect(c.attack).to.be.null
    expect(c.defense).to.be.null
    expect(c.stress).to.be.equal 0
    expect(_.keys c.status).to.be.equivalentArray ['normal']
    expect(c.statusDegree).to.be.equal 0
    expect(c.speed).to.be.equal 0

  it "Should be able to add damage effect up to incapicatated, then become normal", ->
    expect(_.keys @character.status).to.be.equivalentArray ['normal']
    expect(@character.statusDegree).to.be.equal 0
    expect(@character.actions).to.be.equal 'full'
    expect(@character.speed).to.be.equal 0

    @character.addEffect new CharacterEffect {attack: @character.attack, defense: @character.defense, status: (@character.attack.statusByDegree 1)}
    expect(_.keys @character.status).to.be.equivalentArray ['dazed', 'actionPartial']
    expect(@character.statusDegree).to.be.equal 1
    expect(@character.actions).to.be.equal 'partial'
    expect(@character.speed).to.be.equal 0

    @character.addEffect new CharacterEffect {attack: @character.attack, defense: @character.defense, degree: 2}
    expect(_.keys @character.status).to.be.equivalentArray ['staggered', 'dazed', 'actionPartial', 'hindered']
    expect(@character.statusDegree).to.be.equal 2
    expect(@character.actions).to.be.equal 'partial'
    expect(@character.speed).to.be.equal -1
 
    @character.addEffect new CharacterEffect {attack: @character.attack, defense: @character.defense, status: (@character.attack.statusByDegree 3)}
    expect(_.keys @character.status).to.be.equivalentArray ['incapacitated', 'defenseless', 'stunned', 'actionNone', 'unaware', 'prone', 'hindered']
    expect(@character.statusDegree).to.be.equal 3
    expect(@character.actions).to.be.equal 'none'
    expect(@character.speed).to.be.equal -1
 
    @character.addEffect new CharacterEffect {attack: @character.attack, defense: @character.defense, degree: 0}
    expect(@character.statusDegree).to.be.equal 0
    expect(@character.actions).to.be.equal 'full'
    expect(@character.speed).to.be.equal 0

  it "Should be able to add damage effect and affliction effect", ->
    @character.addEffect new CharacterEffect {attack: @attackDamage, defense: @character.defense, degree: 2}
    @character.addEffect new CharacterEffect {attack: @attackAffliction, defense: @character.defense, degree: 2}
    expect(_.keys @character.status).to.be.equivalentArray ['staggered', 'dazed', 'actionPartial', 'hindered', 'disabled']
    expect(@character.statusDegree).to.be.equal 2
    expect(@character.actions).to.be.equal 'partial'
    expect(@character.speed).to.be.equal -1

  it "Should add take no stress on applyHit and degree 2 success", ->
    @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 15
    @character.applyHit @hit
    expect(@character.stress).to.be.equal 0
    expect(_.keys @character.status).to.be.equivalentArray ['normal']
 
  it "Should add stress on applyHit and basic resist success", ->
    @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 10
    @character.applyHit @hit
    expect(@character.stress).to.be.equal 1
    expect(_.keys @character.status).to.be.equivalentArray ['normal']
 
  it "Should add stress and degrree on applyHit failing by 1 degree", ->
    @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 5
    @character.applyHit @hit
    expect(@character.stress).to.be.equal 1
    expect(_.keys @character.status).to.be.equivalentArray ['dazed', 'actionPartial']
 
  it "Should worst that can happen is staggered and 1 stress", ->
    @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 1
    @character.applyHit @hit
    expect(@character.stress).to.be.equal 1
    expect(_.keys @character.status).to.be.equivalentArray ['staggered', 'dazed', 'actionPartial', 'hindered', 'disabled']

  it "Should handle cumulative status for applyHit", ->
    @character.addEffect new CharacterEffect {attack: @character.attack, defense: @character.defense, degree: 2}
    expect(_.keys @character.status).to.be.equivalentArray ['staggered', 'dazed', 'actionPartial', 'hindered']

    @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 4
    @character.applyHit @hit
    expect(@character.stress).to.be.equal 1
    expect(@character.statusDegree).to.be.equal 3
    expect(_.keys @character.status).to.be.equivalentArray ['incapacitated', 'defenseless', 'stunned', 'actionNone', 'unaware', 'prone', 'hindered']

  it "Should handle multiple cumulative status for applyHit", ->
    @attackAffliction = Attack.createAffliction({statuses: ['dazed','staggered','incapacitated'], cumulativeStatuses: ['dazed','staggered']})
    @hit = new AttackResult {attack: @attackAffliction, d20: 15, roll: 25, isCrit: false, degree: 1}

    @character.addEffect new CharacterEffect {attack: @attackAffliction, defense: @character.defense, degree: 2}
    expect(_.keys @character.status).to.be.equivalentArray ['staggered', 'dazed', 'actionPartial', 'hindered']

    @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 9
    @character.applyHit @hit
    expect(@character.stress).to.be.equal 0
    expect(@character.statusDegree).to.be.equal 3
    expect(_.keys @character.status).to.be.equivalentArray ['incapacitated', 'defenseless', 'stunned', 'actionNone', 'unaware', 'prone', 'hindered']

  it "Should be beaten down rolling just enough to take stress", ->  
    while @character.statusDegree < 3
      @character.defense.clearModifiers 'rollCheck'
      # the hit setting a status would clear this modifier
      @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 14
      @character.applyHit @hit 
    expect(@character.stress).to.be.equal 12
    expect(_.keys @character.status).to.be.equivalentArray ['incapacitated', 'defenseless', 'stunned', 'actionNone', 'unaware', 'prone', 'hindered']

  it "Should not be able to recover normal damage", ->
    @character.addEffect new CharacterEffect {attack: @character.attack, defense: @character.defense, status: (@character.attack.statusByDegree 1)}
    @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 20
    @character.endRoundRecovery()
    expect(_.keys @character.status).to.be.equivalentArray ['dazed', 'actionPartial']
    expect(@character.statusDegree).to.be.equal 1

  it "Should be able to recover progressive affliction", ->
    @attackAffliction = Attack.createAffliction({
      statuses: ['dazed','staggered','incapacitated'], 
      isProgressive: true
      })
    @character.addEffect new CharacterEffect {attack: @attackAffliction, defense: @character.defense, status: (@character.attack.statusByDegree 1)}
    @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 20
    @character.endRoundRecovery()
    expect(_.keys @character.status).to.be.equivalentArray ['normal']
    expect(@character.statusDegree).to.be.equal 0

  it "Should be have progressive afflictions get worse", ->
    @attackAffliction = Attack.createAffliction({
      statuses: ['dazed','staggered','incapacitated'], 
      isProgressive: true
      })
    @character.addEffect new CharacterEffect {attack: @attackAffliction, defense: @character.defense, status: (@character.attack.statusByDegree 1)}
    expect(_.keys @character.status).to.be.equivalentArray ['dazed', 'actionPartial']
    expect(@character.statusDegree).to.be.equal 1

    @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 9
    @character.endRoundRecovery()
    expect(_.keys @character.status).to.be.equivalentArray ['staggered', 'dazed', 'actionPartial', 'hindered']
    expect(@character.statusDegree).to.be.equal 2

    @character.addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 9
    @character.endRoundRecovery()
    expect(_.keys @character.status).to.be.equivalentArray ['incapacitated', 'defenseless', 'stunned', 'actionNone', 'unaware', 'prone', 'hindered']
    expect(@character.statusDegree).to.be.equal 3
