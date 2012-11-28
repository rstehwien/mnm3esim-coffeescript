{Simulator} = require('../src/simulator.coffee')

describe "Simulator", ->
  it "Default should run", ->
    s = new Simulator { iterations: 100 }
    results = s.run()
    console.log results
    expect(results.min).to.be.above 0
    expect(results.max).to.be.above 0
    expect(results.min).to.be.below results.max