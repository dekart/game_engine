window.ItemDetailsController = class extends Spine.Controller
  @show: (item)->
    @controller ?= new @()
    @controller.show($(item))

  className: 'item_details'

  constructor: ->
    super

    @.setupEventListeners()

  setupEventListeners: ->
    @el.on('click', '.close', @.onCloseClick)

  show: (item)->
    if item.data('item-details')
      @details = item.data('item-details')

      @.render()
    else
      @el.text(I18n.t('common.loading'))

      $.get(item.data('item-details-url'), (response)=>
        @details = response

        item.data('item-details', @details)

        @.render()

        @.updatePosition(item)
      )

    @el.stop(false, true).appendTo('#content')
      .hide()
      .fadeIn()

    @.updatePosition(item)

  render: ()->
    @html(
      JST['views/item_details'](@)
    )

  updatePosition: (item)->
    @el.position(of: item, my: 'top+5', at: 'bottom', collision: 'flipfit')

  close: ->
    @el.detach()

  onCloseClick: (e)=>
    @.close()
