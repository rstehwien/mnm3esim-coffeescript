{Character} = require('../src/character.coffee')

describe "Status", ->

  it "Should have defaults", ->
    c = new Character
    expect(c.name).to.be.equal 'Character'
    expect(c.initiative).to.be.equal 0
    expect(c.actions).to.be.equal 'full'
    expect(c.isControlled).to.be.false
    expect(c.attack).to.be.null
    expect(c.defense).to.be.null
