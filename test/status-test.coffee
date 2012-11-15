{Status} = require('../src/status.coffee')

describe "Status", ->

  it "Should have the common statuses", ->
    expect(Status.STATUSES['normal'].key).to.equal('normal')
