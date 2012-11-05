window.UpgradeDialogController = class extends Spine.Controller
  @show: ->
    @controller ?= new @()
    @controller.show()

  className: 'upgrade_dialog'

  constructor: ->
    super

  render: ->
    @html(
      JST['views/upgrade_dialog'](@)
    )

  show: ->
    @el.text(I18n.t('common.loading'))

    $.getJSON('/characters/current/upgrade', @.onDataLoad)

    $.dialog(@el)

    @.setupEventListeners()

  close: ->
    $.dialog.close()

  setupEventListeners: ->
    $(document).one('close.dialog', @.onDialogClose)

    @el.on('click', '.increase', @.onIncreaseClick)
    @el.on('click', '.decrease', @.onDecreaseClick)

    @el.on('click', 'button.save:not(.disabled)', @.onSaveButtonClick)
    @el.on('click', 'button.close', @.onCloseButtonClick)

  unbindEventListeners: ->
    @el.off('click', '.increase', @.onIncreaseClick)
    @el.off('click', '.decrease', @.onDecreaseClick)

    @el.off('click', 'button.save:not(.disabled)', @.onSaveButtonClick)
    @el.off('click', 'button.close', @.onCloseButtonClick)

  onDataLoad: (response)=>
    @character = response
    @changes = {}

    @.render()

  onDialogClose: ()=>
    @.unbindEventListeners()

  onIncreaseClick: (e)=>
    attribute = $(e.currentTarget).parent().data('attribute')

    if @.canIncrease(attribute)
      @character.points -= @character.upgrade_cost[attribute]
      @changes[attribute] ?= 0
      @changes[attribute] += @character.upgrade_increase[attribute]

      @.render()

  onDecreaseClick: (e)=>
    attribute = $(e.currentTarget).parent().data('attribute')

    if @.canDecrease(attribute)
      @changes[attribute] -= @character.upgrade_increase[attribute]
      @character.points += @character.upgrade_cost[attribute]

      @.render()

  onSaveButtonClick: (e)=>
    $.post(
      '/characters/current/upgrade'

      _.reduce(@changes
        (result, value, attribute)=>
          result[attribute] = value / @character.upgrade_increase[attribute]
          result
        {}
      )

      @.onDataLoad
    )

  onCloseButtonClick: (e)=>
    @.close()

  canIncrease: (attribute)->
    @character.points >= @character.upgrade_cost[attribute]

  canDecrease: (attribute)->
    @changes[attribute] and @changes[attribute] > 0

  isChanged: ->
    _.reduce(
      @changes
      (sum, change)-> sum + change
      0
    ) > 0