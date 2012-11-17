{Defense, ResistResult} = require('../src/defense.coffee')
{AttackResult} = require('../src/attack.coffee')

describe "Defense", ->

  it "Should have defaults", ->
    m = new Defense
    expect(m.value).to.be.equal 10
    expect(m.save).to.be.equal 10
    expect(m.impervious).to.be.null
