_ = require 'underscore'
chai = require 'chai'
chai.should()
global.expect = chai.expect
global.assert = chai.assert
global['_'] = _

Assertion = chai.Assertion

Assertion.addMethod 'equivalentArray', (otherArray) ->
  array = @_obj

  expect(array).to.be.an.instanceOf(Array)
  expect(otherArray).to.be.an.instanceOf(Array)

  diff = _.difference array, otherArray

  @assert(
    diff.length is 0, 
    'expected #{this} to be equal to #{exp} (order independant)',
    array,
    otherArray
    )