{utils} = require('../src/utils.coffee')

generateExpectedDegrees = (dc) ->
  # [Check Result Equal or Greater Than DC + X, Degree]
  # test at each X+1, X, and X-1
  [
    [dc+16,4], [dc+15,4], [dc+14,3],
    [dc+11,3], [dc+10,3], [dc+9,2],
    [dc+6,2],  [dc+5,2],  [dc+4,1],
    [dc+1,1],  [dc+0,1],  [dc-1,-1],
    [dc-4,-1], [dc-5,-1], [dc-6,-2],
    [dc-9,-2], [dc-10,-2],[dc-11,-3],
    [dc-14,-3],[dc-15,-3],[dc-16,-4],
    [dc-19,-4],[dc-20,-4],[dc-21,-5]
  ]

describe "utils", ->

  it "Should roll between 1 and 20", ->
    for i in [1...10000]
      expect(utils.rollD20()).to.be.within(1, 20)

  it "Should roll between 6 and 25", ->
    for i in [1...10000]
      expect(utils.rollD20(5)).to.be.within(6, 25)

  it "Should roll between -6 and 13", ->
    for i in [1...10000]
      expect(utils.rollD20(-7)).to.be.within(-6, 13)

  it "Should calculate the correct degree", ->
    dc = 20
    for v in generateExpectedDegrees(dc)
      expect(utils.checkDegree(dc, v[0])).to.be.equal(v[1])

  it "Should get statistics", ->
    s = utils.statistics [1,2,3]
    expect(s.min).to.equal 1
    expect(s.max).to.equal 3
    expect(s.mean).to.equal 2
    expect(s.median).to.equal 2
    expect(s.variance).to.equal 1
    expect(s.standardDeviation).to.equal 1
    expect(utils.formatStatBlock s).to.equal '              min: 1\n              max: 3\n             mean: 2\n           median: 2\n         variance: 1\nstandardDeviation: 1'

