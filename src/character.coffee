{Modifiable} = require './modifiable.coffee'

class Character extends Modifiable
  constructor: (values) ->
    modifiable =
      initiative  : 0,
      actions     : 'full',
      isControlled: false

    properties =
      name        : "Character",
      attack      : null,
      defense     : null,

    super modifiable, properties, values
  
  
module.exports =
  Character: Character
