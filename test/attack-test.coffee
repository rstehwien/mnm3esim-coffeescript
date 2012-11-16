{Attack, AttackResult} = require('../src/attack.coffee')

describe "Status", ->

  it "Should have defaults", ->
    a = new Attack
    expect(a.bonus).to.be.equal 10
    expect(a.rank).to.be.equal 10
    expect(a.penetrating).to.be.equal 0
    expect(a.minCrit).to.be.equal 20
    expect(a.isCauseStress).to.be.true
    expect(a.isPerceptionAttack).to.be.false
    expect(a.isStatusRecovery).to.be.false
    expect(a.isProgressive).to.be.false
    expect(a.isMultiattack).to.be.false
    expect(a.cumulativeStatuses).to.be.equivalentArray ['staggered']
    expect(a.statuses).to.be.equivalentArray ['dazed','staggered','incapacitated']
