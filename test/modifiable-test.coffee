Modifiable = require('../src/modifiable.coffee').Modifiable

describe "Modifiable", ->

  it "Should add the properties", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}
    for k in ["jagger", "_jagger", "elvis", "_elvis"]
      expect(m).to.have.property(k)

  it "Should have the right values", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}
    expect(m.jagger).to.equal 'Rock'
    expect(m.elvis).to.equal 'Roll'

  it "Should have be able to set values", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}
    expect(m.jagger).to.equal 'Rock'
    expect(m.elvis).to.equal 'Roll'

    m.jagger = 'Lips'
    m.elvis = 'Hips'
    expect(m.jagger).to.equal 'Lips'
    expect(m.elvis).to.equal 'Hips'
    