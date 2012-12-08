{Simulator} = require('../src/simulator.coffee')
{Character, CharacterEffect} = require('../src/character.coffee')
{Status, StatusModifier} = require('../src/status.coffee')
{Defense, ResistResult} = require('../src/defense.coffee')

describe "Simulator", ->
  beforeEach ->
    @s = new Simulator { iterations: 1000 }

  it "Default should run", ->
    results = @s.run()
    expect(results.min).to.be.above 0
    expect(results.max).to.be.above 0
    expect(results.min).to.be.below results.max

  it "Combat should finish when one incapacitated", ->
    @s._initRun()
    @s._initCombat()
    @s.team2[0].addEffect new CharacterEffect {attack: @s.team1[0].attack, defense: @s.team2[0].defense, degree: 3}
    expect(@s._isCombatFinished()).to.be.true

  it "Attacker can one-shot defender in _runRound", ->
    @s._initRun()
    @s._initCombat()
    @s.team1[0].addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 20
    @s.team2[0].addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 1
    @s._runRound()
    expect(@s._isCombatFinished()).to.be.true
    expect(@s.team1[0].statusDegree).to.be.equal 0
    expect(@s.team2[0].statusDegree).to.be.equal 3

  it "Attacker can one-shot self if controlled", ->
    @s.team1[0].defense = new Defense
    @s._initRun()
    @s._initCombat()

    # make attacker controlled so he would attack self
    @s.team1[0].addStatusModifier Status.allModifiers('actionsControlled')[0]
    expect(@s.team1[0].isControlled).to.be.true

    # attack rolls 20 and both defenses roll 1
    @s.team1[0].attack.addModifier 'rollCheck', (x) -> 20
    @s.team1[0].defense.addModifier 'rollCheck', (x) -> 1
    @s.team2[0].addStatusModifier new StatusModifier 'ALL', 'rollCheck', (x) -> 1

    @s._runRound()
    expect(@s._isCombatFinished()).to.be.true
    expect(@s.team1[0].statusDegree).to.be.equal 3
    expect(@s.team2[0].statusDegree).to.be.equal 0
