{Modifiable} = require('../src/modifiable.coffee')

class Rockers extends Modifiable
  constructor: (values) ->
    modifiable = {jagger: "Rock", elvis: "Roll"}
    properties = {chuck: "Balls of Fire"}
    super modifiable, properties, values

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
    expect(-> m.addModifier 'dio', (v) -> "Great #{v}").to.throw '\'dio\' cannot be modified'
    expect(m.dio).to.equal 'Heavy'

  it "Should roll between 3 and 22", ->
    m = new Modifiable
    m.addModifier 'rollCheck', (v) -> (v + 2)
    for i in [1...10000]
      expect(m.rollCheck()).to.be.within(3, 22)

  it "Should get the right degree", ->
    m = new Modifiable
    expect(m.checkDegree 13, 10).to.equal -1
    expect(m.checkDegree 19, 19).to.equal 1

  it "Should rockers subclass defaults", ->
    m = new Rockers
    expect(m.jagger).to.equal 'Rock'
    expect(m.elvis).to.equal 'Roll'
    expect(m.chuck).to.equal 'Balls of Fire'

  it "Should be able to set rockers values", ->
    m = new Rockers {chuck: "Piano", elvis: "Hips", jagger: "Lips"}
    expect(m.jagger).to.equal 'Lips'
    expect(m.elvis).to.equal 'Hips'
    expect(m.chuck).to.equal 'Piano'

  it "Should be default rocker values when setting one", ->
    m = new Rockers {elvis: "Hips"}
    expect(m.jagger).to.equal 'Rock'
    expect(m.elvis).to.equal 'Hips'
    expect(m.chuck).to.equal 'Balls of Fire'

  it "Should be to modify modifiable", ->
    m = new Rockers {elvis: "Hips"}
    m.addModifier 'jagger', (v) -> "Lip #{v}"
    expect(m.jagger).to.equal 'Lip Rock'
    expect(-> m.addModifier 'chuck', (v) -> "Great #{v}").to.throw '\'chuck\' cannot be modified'

  it "Should be throw error for invalid property", ->
    expect(-> new Rockers {dio: "Holy Diver"}).to.throw 'Invalid property \'dio\''
