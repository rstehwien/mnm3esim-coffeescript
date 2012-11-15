{Modifiable} = require('../src/modifiable.coffee')

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
    expect(m.jagger).to.equal 'Lip Rock'
    expect(m.elvis).to.equal 'Hip Roll'

    m.clearModifiers()
    expect(m.jagger).to.equal 'Rock'
    expect(m.elvis).to.equal 'Roll'

  it "Should chain modifiers", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}
    m.addModifier 'jagger', (v) -> "Lip #{v}"
    m.addModifier 'jagger', (v) -> "Big #{v}"
    expect(m.jagger).to.equal 'Big Lip Rock'

  it "Should add the modifiable and values", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}, {elvis: 'Hips', dio: 'Heavy'}
    expect(m.jagger).to.equal 'Rock'
    expect(m.elvis).to.equal 'Hips'
    expect(m.dio).to.equal 'Heavy'

  it "Should add be able to set non-modifiable", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}, {elvis: 'Hips', dio: 'Heavy'}
    expect(m.dio).to.equal 'Heavy'
    m.dio = 'Holy Diver'
    expect(m.dio).to.equal 'Holy Diver'

  it "Should should not modify (unmoifiable) values", ->
    m = new Modifiable {jagger: "Rock", elvis: "Roll"}, {elvis: 'Hips', dio: 'Heavy'}
    m.addModifier 'ALL', (v) -> "Ready to #{v}"
    expect(m.jagger).to.equal 'Ready to Rock'
    expect(m.elvis).to.equal 'Ready to Hips'
    expect(m.dio).to.equal 'Heavy'

    m.addModifier 'dio', (v) -> 'Holy Diver #{v}'
    expect(m.dio).to.equal 'Heavy'
    m.dio = 'Holy Diver'
    expect(m.dio).to.equal 'Holy Diver'

  it "Should roll between 3 and 22", ->
    m = new Modifiable
    m.addModifier 'rollCheck', (v) -> (v + 2)
    for i in [1...10000]
      expect(m.rollCheck()).to.be.within(3, 22)

  it "Should roll between -1 and 18 using ALL", ->
    m = new Modifiable
    m.addModifier 'ALL', (v) -> (v - 2)
    for i in [1...10000]
      expect(m.rollCheck()).to.be.within(-1, 18)

  it "Should get the right degree", ->
    m = new Modifiable
    expect(m.checkDegree 13, 10).to.equal -1
    expect(m.checkDegree 19, 19).to.equal 1

