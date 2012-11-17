{Status, StatusModifier} = require('../src/status.coffee')

describe "Status", ->

  it "Should have the common statuses", ->
    expect(Status.STATUSES['normal'].key).to.equal('normal')

  it "Should expand null as normal", ->
    s = Status.expandStatuses(null)
    expect(_.keys s).to.be.equivalentArray(['normal'])

  it "Should expand normal as normal", ->
    s = Status.expandStatuses('normal')
    expect(_.keys s).to.be.equivalentArray(['normal'])

  it "Should expand impaired array as impaired", ->
    s = Status.expandStatuses(['impaired'])
    expect(_.keys s).to.be.equivalentArray(['impaired'])

  it "Should replace duplicates in impaired and disabled", ->
    s = Status.expandStatuses(['impaired', 'disabled'])
    expect(_.keys s).to.be.equivalentArray(['disabled'])

  it "Should throw error for invalid status", ->
    expect(-> Status.expandStatuses('smeggle')).to.throw 'Invalid status \'smeggle\''

  it "Should expand incapacitated", ->
    s = Status.expandStatuses(['incapacitated'])
    expect(_.keys s).to.be.equivalentArray(['defenseless', 'incapacitated', 'stunned', 'actionNone', 'unaware', 'prone', 'hindered'])

  it "Should have the right modifiers in incapacitated", ->
    m = Status.allModifiers(['incapacitated'])
    expect(m.length).to.equal(4)
    for v in m
      #expect(v).to.be.a('StatusModifier')
      expect(v instanceof StatusModifier).to.be.true
      expect(v.group).to.be.a('string')
      expect(v.property).to.be.a('string')
      expect(v.modifier).to.be.a('Function')
      expect(v.description is undefined or typeof v.description is 'string').to.be.true

  it "Should get 0 for normal degree", ->
    expect(Status.degree 'normal').to.equal 0

  it "Should get 1 for ['hindered'] degree", ->
    expect(Status.degree ['hindered']).to.equal 1

  it "Should get 1 for ['dazed','fatigued','hindered'] degree", ->
    expect(Status.degree ['dazed','fatigued','hindered']).to.equal 1

  it "Should get 2 for ['stunned'] degree", ->
    expect(Status.degree ['stunned']).to.equal 2

  it "Should get 2 for ['dazed','fatigued','stunned', 'hindered'] degree (worst degree)", ->
    expect(Status.degree ['dazed','fatigued','stunned', 'hindered']).to.equal 2

  it "Should get 3 for ['dazed','transformed','stunned'] degree (worst degree)", ->
    expect(Status.degree ['dazed','transformed','stunned']).to.equal 3

  it "Should get 3 for ['incapacitated'] degree", ->
    expect(Status.degree ['incapacitated']).to.equal 3
