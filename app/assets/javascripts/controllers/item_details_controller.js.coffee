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
    @el.on('mouseenter', @.onMouseEnter)
    @el.on('mouseleave', @.onMouseLeave)

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

  close: (fade)->
    if fade
      @el.fadeOut(()=> @el.detach())
    else
      @el.detach()

  onCloseClick: (e)=>
    @.close()

  onMouseLeave: (e)=>
    @mouse_left = true

    @.setMouseLeftTimeout(1000)

  onMouseEnter: (e)=>
    @mouse_left = false

    @.setMouseLeftTimeout(false)

  onMouseLeftTimeout: =>
    @.close(true) if @mouse_left

  setMouseLeftTimeout: (timeout)->
    clearTimeout(@mouse_left_timer) if @mouse_left_timer

    if timeout
      @mouse_left_timer = setTimeout(@.onMouseLeftTimeout, 1000)