{Character} = require('../src/character.coffee')
{Status} = require('../src/status.coffee')
{Attack, AttackResult} = require('../src/attack.coffee')
{Defense, ResistResult} = require('../src/defense.coffee')
_ = require 'underscore'

describe "Character", ->

  beforeEach () ->
    @character = new Character {attack: Attack.createDamage(), defense: new Defense}

  it "Should have defaults", ->
    c = new Character
    expect(c.name).to.be.equal 'Character'
    expect(c.initiative).to.be.equal 0
    expect(c.actions).to.be.equal 'full'
    expect(c.isControlled).to.be.false
    expect(c.attack).to.be.null
    expect(c.defense).to.be.null
    expect(c.stress).to.be.equal 0
    expect(c.effects).to.eql {}
    expect(_.keys c.status).to.be.equivalentArray ['normal']
    expect(c.statusDegree).to.be.equal 0
