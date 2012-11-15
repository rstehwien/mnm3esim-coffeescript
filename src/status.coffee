_ = require 'underscore'

class Status
  constructor: (value = {}) ->
    def = 
      key: 'normal'
      degree: 0
      recovery: false
      replace: null
      modifiers: null

    value = _.extend def, value
    @key = value.key
    @degree = value.degree
    @recovery = value.recovery
    @replace = value.replace
    @modifiers = value.modifiers

    Status.STATUSES[@key] = this

  @STATUSES = null

  @_init: ->
    return if @STATUSES isnt null
    @STATUSES = {}

    # ALL STANDARD STATUSES
    standardStatuses = [
      {
        key: 'normal'
        degree: 0
        recovery: false
        replace: null
        modifiers: null
      }

      ########################################
      # BASIC CONDITIONS
      ########################################

      # COMPELLED: action chosen by controller, limited to free actions and a single standard action per turn
      {
        key: 'compelled'
        degree: 2
        recovery: false
        replace: null
        modifiers: ['actionPartial', 'actionsControlled']
      }

      # CONTROLLED: full actions chosen by controller
      {
        key: 'controlled'
        degree: 3
        recovery: false
        replace: ['compelled']
        modifiers: ['actionsControlled']
      }

      # DAZED: limited to free actions and a single standard action per turn
      {
        key: 'dazed'
        degree: 1
        recovery: false
        replace: null
        modifiers: ['actionPartial']
      }

      # DEBILITATED: The character has one or more abilities lowered below –5.
      {
        key: 'debilitated'
        degree: 3
        recovery: false
        replace: ['disabled', 'weakened']
        modifiers: ['actionNone']
      }

      # DEFENSELESS: defense = 0
      {
        key: 'defenseless'
        degree: 2
        recovery: false
        replace: ['vulnerable']
        modifiers: [['defense', 'value', ((x) -> 0), 'defenseless']]
      }

      # DISABLED: checks - 5 
      {
        key: 'disabled'
        degree: 2
        recovery: false
        replace: ['impaired']
        modifiers: [['ALL', 'rollCheck', ((x) -> x - 5), 'disabled; -5 to checks']]
      }

      # FATIGUED: hindered, recover in an hour
      {
        key: 'fatigued'
        degree: 1
        recovery: false
        replace: null
        modifiers: ['hindered']
      }

      # HINDERED: speed - 1 (half speed)
      {
        key: 'hindered'
        degree: 1
        recovery: false
        replace: null
        modifiers: [['character', 'speed', ((x) -> x - 1), 'hindered: -1 speed']]
      }

      # IMMOBLE:
      {
        key: 'immobile'
        degree: 2
        recovery: false
        replace: ['hindered']
        modifiers: [['character', 'speed', ((x) -> null), 'immoble: no speed']]
      }

      # IMPAIRED: checks - 2 
      {
        key: 'impaired'
        degree: 1
        recovery: false
        replace: null
        modifiers: [['ALL', 'rollCheck', ((x) -> x - 2), 'impaired; -2 to checks']]
      }

      # STUNNED:
      {
        key: 'stunned'
        degree: 2
        recovery: false
        replace: ['dazed']
        modifiers: ['actionNone']
      }

      # TRANSFORMED: becomes something else
      {
        key: 'transformed'
        degree: 3
        recovery: false
        replace: null
        modifiers: ['actionNone']
      }

      # UNAWARE:unaware of surroundings and unable to act on it
      {
        key: 'unaware'
        degree: 3
        recovery: false
        replace: null
        modifiers: ['actionNone']
      }

      # VULNERABLE: defense.value/2 [RU]
      {
        key: 'vulnerable'
        degree: 1
        recovery: false
        replace: null
        modifiers: [['defense', 'value', ((x) -> Math.ceil(x/2.0)), 'vulnerable: 1/2 defense']]
      }

      # WEAKENED: trait is lowered
      {
        key: 'weakened'
        degree: 1
        recovery: false
        replace: null
        modifiers: null
      }

      ########################################
      # COMBINED CONDITIONS
      ########################################

      # ASLEEP: perception degree 3 removes, sudden movement removes
      {
        key: 'asleep'
        degree: 3
        recovery: false
        replace: null
        modifiers: ['defenseless', 'stunned', 'unaware']
      }

      # BLIND:
      {
        key: 'blind'
        degree: 2
        recovery: false
        replace: null
        modifiers: ['hindered', 'unaware', 'vulnerable', 'impaired']
      }

      # BOUND:
      {
        key: 'bound'
        degree: 2
        recovery: false
        replace: null
        modifiers: ['defenseless', 'immobile', 'impaired']
      }

      # DEAF:
      {
        key: 'deaf'
        degree: 2
        recovery: false
        replace: null
        modifiers: ['unaware']
      }

      # DYING:
      {
        key: 'dying'
        degree: 4
        recovery: false
        replace: null
        modifiers: ['incapacitated']
      }

      # ENTRANCED: take no action, any threat ends entranced
      {
        key: 'entranced'
        degree: 1
        recovery: true
        replace: null
        modifiers: ['actionNone']
      }

      # EXHAUSTED:
      {
        key: 'exhausted'
        degree: 2
        recovery: false
        replace: ['fatigued']
        modifiers: ['impaired', 'hindered']
      }

      # INCAPICITATED:
      {
        key: 'incapacitated'
        degree: 3
        recovery: false
        replace: null
        modifiers: ['defenseless', 'stunned', 'unaware', 'prone']
      }

      # PARALYZED: Physically immobile but can take purely mental actions
      {
        key: 'paralyzed'
        degree: 3
        recovery: false
        replace: null
        modifiers: ['defenseless', 'immobile', 'stunned']
      }

      # PRONE:
      #   really gives close attacks +5 and ranged -5 but for purposes of the sim the status effect was worst case
      {
        key: 'prone'
        degree: 2
        recovery: false
        replace: null
        modifiers: ['hindered', ['defense', 'value', ((x) -> x - 5), 'prone: -5 defense']]
      }

      # RESTRAINED:
      {
        key: 'restrained'
        degree: 2
        recovery: false
        replace: null
        modifiers: ['hindered', 'vulnerable']
      }

      # STAGGERED:
      {
        key: 'staggered'
        degree: 2
        recovery: false
        replace: null
        modifiers: ['dazed', 'hindered']
      }

      # SUPRISED:
      {
        key: 'suprised'
        degree: 1
        recovery: true
        replace: null
        modifiers: ['stunned', 'vulnerable']
      }

      ########################################
      # SPECIAL CONDITONS FOR PROGRAM
      ########################################

      {
        key: 'actionPartial'
        degree: 0
        recovery: false
        replace: null
        modifiers: [['character', 'actions', ((x) -> 'partial'), 'partial actions']]
      }

      {
        key: 'actionNone'
        degree: 0
        recovery: false
        replace: ['actionPartial']
        modifiers: [['character', 'actions', ((x) -> 'none'), 'no actions']]
      }

      {
        key: 'actionsControlled'
        degree: 0
        recovery: false
        replace: null
        modifiers: [['character', 'isControlled', ((x) -> true), 'actions controlled']]
      }
    ]

    new Status(s) for s in standardStatuses

Status._init()

module.exports =
  Status: Status
