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
      )

    offset = item.offset()

    @el.stop(false, true).appendTo('#content')
      .position(of: item, my: 'right top', at: 'left top', collision: 'flipfit')
      .hide()
      .fadeIn()

  render: ()->
    @html(
      JST['views/item_details'](@)
    )

  close: ->
    @el.detach()

  onCloseClick: (e)=>
    @.close()