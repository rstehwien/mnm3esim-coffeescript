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

module.exports =
  utils: Utils
