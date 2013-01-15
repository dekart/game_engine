#= require controllers/dialog_controller

window.AppRequestDialogController = class extends DialogController
  @show: ->
    @controller ?= new @()
    @controller.show()

  className: 'dialog app_requests'

  show: ->
    @loading = true

    $.getJSON('/app_requests.json', @.onDataLoad)

    super

  setupEventListeners: ->
    super

    @el.on('click', '.invitation button', @.onInvitationButtonClick)
    @el.on('click', '.gift button', @.onInvitationButtonClick)

  unbindEventListeners: ->
    super

#    @el.off('click', '.relation', @.onRelationClick)

  render: ->
    @.updateContent(
      if @requests
        @.renderTemplate('app_requests/list', @)
      else
        I18n.t('common.loading')
    )

    @el.find('.content').tabs()

  onDataLoad: (response)=>
    @loading = false

    @requests = response

    @.render()

  onInvitationButtonClick: (e)=>
    button = $(e.currentTarget)

    button.addClass('disabled')

    $.ajax(
      url: "/app_requests/#{ button.data('request-id') }"
      type: 'PUT'
      success: (r)=>
        console.log(r)
        @.hideRequestByButton(button)
    )

  onGiftButtonClick: (e)=>
    button = $(e.currentTarget)

    button.addClass('disabled')

    $.ajax(
      url: "/app_requests/#{ button.data('request-id') }"
      type: 'PUT'
      success: (r)=>
        console.log(r)
        @.hideRequestByButton(button)
    )

  hideRequestByButton: (b)->
    b.parents('.request').fadeOut()