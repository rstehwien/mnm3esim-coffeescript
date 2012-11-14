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

  it "Should use modifiers", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}
    m.addModifier 'jagger', (v) -> "Lip #{v}"
    expect(m.jagger).to.equal 'Lip Rock'
    expect(m.elvis).to.equal 'Roll'

  it "Should use 'ALL' modifier", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}
    m.addModifier 'ALL', (v) -> "Ready to #{v}"
    expect(m.jagger).to.equal 'Ready to Rock'
    expect(m.elvis).to.equal 'Ready to Roll'

  it "Should should be able to clear specific modifier", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}
    m.addModifier 'jagger', (v) -> "Lip #{v}"
    m.addModifier 'elvis', (v) -> "Hip #{v}"
    expect(m.jagger).to.equal 'Lip Rock'
    expect(m.elvis).to.equal 'Hip Roll'

    m.clearModifiers 'jagger'
    expect(m.jagger).to.equal 'Rock'
    expect(m.elvis).to.equal 'Hip Roll'

  it "Should should be able to clear all modifiers", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}
    m.addModifier 'jagger', (v) -> "Lip #{v}"
    m.addModifier 'elvis', (v) -> "Hip #{v}"
    #expect(m.jagger).to.equal 'Lip Rock'
    #expect(m.elvis).to.equal 'Hip Roll'

    m.clearAllModifiers()
    expect(m.jagger).to.equal 'Rock'
    expect(m.elvis).to.equal 'Roll'


  it "Should chain modifiers", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}
    m.addModifier 'jagger', (v) -> "Lip #{v}"
    m.addModifier 'jagger', (v) -> "Big #{v}"
    expect(m.jagger).to.equal 'Big Lip Rock'
