_ = require 'underscore'
_.str = require 'underscore.string'

class Utils
  @rollD20: (bonus=0) ->
    Math.floor(Math.random() * 20) + 1 + bonus

  @checkDegree: (difficulty, check) ->
    result = check - difficulty
    Math.floor(result/5) + (if result < 0 then 0 else 1)

  @increaseDegree: (degree, inc = 1) ->
    isNeg = degree < 0
    degree += inc
    if isNeg and degree >= 0 then degree + 1 else degree

  @makeArray: (obj) ->
    if not obj? 
      return []
    else if _.isArray obj
      return obj
    else
      return [obj]

  @statistics: (a) -> 
    result = {}

    result.min = _.min a
    result.max = _.max a

    total = _.reduce a, ((sum, x) -> sum + x), 0
    mean = total / a.length
    result.mean = mean

    sorted = a.sort()
    idx = Math.floor a.length/2
    result.median = if a.length % 2 == 1 then sorted[idx] else (sorted[idx - 1] + sorted[idx]) / 2

    sv = _.reduce a, ((accum, i) -> accum + (Math.pow (i - mean), 2)), 0
    variance = sv / (a.length - 1)
    result.variance = variance
    result.standardDeviation =  Math.sqrt variance

    result

  @formatStatBlock: (s) ->
    order = ['min', 'max', 'mean', 'median', 'variance', 'standardDeviation']
    stats = ("#{_.str.pad (k+':'), 18} #{s[k]}" for k in order)
    stats.join '\n'

module.exports =
  utils: Utils
