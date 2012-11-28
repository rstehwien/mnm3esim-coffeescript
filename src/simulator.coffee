{utils} = require './utils.coffee'
{Modifiable} = require './modifiable.coffee'
{Attack} = require('./attack.coffee')
{Defense} = require('./defense.coffee')
{Character} = require('./character.coffee')
_ = require 'underscore'

class Simulator extends Modifiable
  constructor: (values={}) ->
    properties =
      iterations: 10000
      team1: [new Character {name: "Attacker", attack: new Attack}]
      team2: [new Character {name: "Defender", defense: new Defense}]
      _initOrder: null
      _numRounds: null

    super null, properties, values

  run: ->
    @_initRun()
    @_runCombat() for i in [1..@iterations]
    utils.statistics @_numRounds

  _initRun: ->
      @_numRounds = []

  _initCombat: ->
      characters = @team1.concat @team2
      c.initCombat() for c in characters
      @_initOrder = _.sortBy characters, (c) -> c.initiativeValue

  _runCombat: ->
      @_initCombat()

      rounds = 0
      while not @_isCombatFinished() and rounds < 10000
        rounds += 1
        @_runRound()

      @_numRounds.push rounds

  _isCombatFinished: ->
    for c in @_initOrder
      return true if c.statusDegree > 2
    return false

  _runRound: ->
    for c in @_initOrder
      continue if c.actions is 'none'

      # determine and attack the target
      if c.isControlled
        target = if c in @team1 then @team1[0] else @team2[0]
      else
        target = if c in @team1 then @team2[0] else @team1[0]
      c.attack.attack target if c.attack?

      return if @_isCombatFinished()

      c.endRoundRecovery()


module.exports =
  Simulator      : Simulator
