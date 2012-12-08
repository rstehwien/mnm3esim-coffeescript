_ = require 'underscore'
_.str = require 'underscore.string'

{utils} = require './utils.coffee'
require './modifiable.coffee'
require './status.coffee'
{Attack} = require './attack.coffee'
{Defense} = require './defense.coffee'
{Character} = require './character.coffee'
{Simulator} = require './simulator.coffee'

runSim = (name, attack) ->
  attacker = new Character {name: "Atacker", attack: attack}
  defender = new Character {name: "Defender", defense: new Defense}

  simulator = new Simulator {team1: [attacker], team2: [defender]}
  result = utils.formatStatBlock simulator.run()
  console.log "==========\n#{name}\n#{result}\n=========="

runSim("BASIC DAMAGE", Attack.createDamage())

afflictions = [
  {name: "DAMAGE", options: {statuses: ['dazed','staggered','incapacitated']}},
  {name: "DEFENSE", options: {statuses: ['vulnerable','defenseless','incapacitated']}},
  {name: "IMPAIR", options: {statuses: ['impaired','disabled','incapacitated']}},
]

extras = [
  {name: "", extras: {}},
  {name: "CUMULATIVE", options: {cumulativeStatuses: [1,2]}},
  {name: "PROGRESSIVE", options: {isProgressive: true}},
  {name: "CUMULATIVE+PROGRESSIVE", options: {cumulativeStatuses: [1,2], isProgressive: true}},
  {name: "STRESSFUL", options: {isCauseStress: true}},
]

for affliction in afflictions
  for extra in extras
    name = _.str.trim "AFFLICTION: #{affliction.name} #{extra.name}"
    options = _.extend affliction.options, extra.options
    attack = Attack.createAffliction options
    runSim name, attack
