{Defense, ResistResult} = require('../src/defense.coffee')

describe "Status", ->

  it "Should have defaults", ->
    m = new Defense
    expect(m.value).to.be.equal 10
    expect(m.save).to.be.equal 10
    expect(m.impervious).to.be.null
