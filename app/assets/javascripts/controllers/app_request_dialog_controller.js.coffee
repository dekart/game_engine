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

    @el.on('click', '.request:not(.gift) button', @.onAcceptClick)
    @el.on('click', '.request.gift button', @.onGiftAcceptClick)
    @el.on('click', '.request .ignore', @.onIgnoreClick)

  unbindEventListeners: ->
    super

    @el.off('click', '.request button', @.onAcceptClick)
    @el.off('click', '.request .ignore', @.onIgnoreClick)

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

  onAcceptClick: (e)=>
    e.preventDefault()

    button = $(e.currentTarget)
    button.addClass('disabled')

    $.ajax(
      url: "/app_requests/accept.json"
      type: 'PUT'
      data:
        ids: button.data('request-id')
      success: (r)=>
        @.processAcceptResponse(r)
        @.hideRequestByControl(button)
    )

  onGiftAcceptClick: (e)=>
    e.preventDefault()

    button = $(e.currentTarget)
    button.addClass('disabled')

    $.ajax(
      url: "/app_requests/accept.json"
      type: 'PUT'
      data:
        ids: button.data('request-id')
      success: (r)=>
        sender_ids = button.parents('.request').data('sender-id')

        @.sendGiftBack(
          r.target
          if _.isNumber(sender_ids) then [sender_ids] else parseInt(i) for i in sender_ids.split(',')
        )
        @.processAcceptResponse(r)
        @.hideRequestByControl(button)
    )

  onIgnoreClick: (e)=>
    e.preventDefault()

    link = $(e.currentTarget)

    link.addClass('disabled')

    $.ajax(
      url: "/app_requests/ignore.json"
      type: 'PUT'
      data:
        ids: link.data('request-id')
      success: (r)=>
        @.hideRequestByControl(link)
    )

  processAcceptResponse: (response)->
    if response.next_page
      redirectTo(response.next_page)

    GA.appRequestAccepted(response.type, response.target?.name, response.count)

  hideRequestByControl: (b)->
    text = b.data('accepted')
    request = b.parents('.request')

    request.find('.controls').html(text) if text
    request.fadeOut('slow')

  sendGiftBack: (target, ids)->
    new InviteDialog('gift',
      dialog:
        to: ids
        title: I18n.t('app_requests.invites.gift.title', item: target.name)
        message: I18n.t('app_requests.invites.gift.message', item: target.name, app: I18n.t('app_name'))
        data:
          target_id: target.id
          target_type: 'Item'
      request:
        target_id: target.id
        target_type: 'Item'
    )