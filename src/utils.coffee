class Utils
  @rollD20: (bonus=0) ->
    Math.floor(Math.random() * 20) + 1 + bonus

  @checkDegree: (difficulty, check) ->
    result = check - difficulty
    Math.floor(result/5) + (if result < 0 then 0 else 1)

module.exports =
  utils: Utils
