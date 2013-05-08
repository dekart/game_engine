#= require controllers/dialog_controller

window.RefillDialogController = class extends DialogController
  show: ->
    @loading = true

    $.getJSON("/premium/refill?type=#{ @.refillAttribute }", @.onDataLoad)

    super

  setupEventListeners: ->
    super

    @el.on('click', '.options .option.vip_money button:not(.disabled)', @.onVipMoneyRefillClick)
    @el.on('click', '.options .option.item button:not(.disabled)', @.onItemRefillClick)

  unbindEventListeners: ->
    super

    @el.off('click', '.options .option.vip_money button:not(.disabled)', @.onVipMoneyRefillClick)
    @el.off('click', '.options .option.item button:not(.disabled)', @.onItemRefillClick)

  onDataLoad: (response)=>
    @loading = false

    @status = response

    @.render()

  onVipMoneyRefillClick: (e)=>
    $(e.currentTarget).addClass('disabled')

    $.ajax("/premium?type=refill_#{ @.refillAttribute }", type: 'PUT', complete: =>
      @.close()
    )

  onItemRefillClick: (e)=>
    button = $(e.currentTarget)

    button.addClass('disabled')

    $.post("/inventories/#{ button.data('item') }/use", =>
      @.close()
    )