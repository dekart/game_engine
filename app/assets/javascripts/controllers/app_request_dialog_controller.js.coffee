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

    @el.on('click', '.request:not(.gift) button:not(.disabled)', @.onAcceptClick)
    @el.on('click', '.request.gift button:not(.disabled)', @.onGiftAcceptClick)
    @el.on('click', '.request .ignore:not(.disabled)', @.onIgnoreClick)

  unbindEventListeners: ->
    super

    @el.off('click', '.request:not(.gift) button:not(.disabled)', @.onAcceptClick)
    @el.off('click', '.request.gift button:not(.disabled)', @.onGiftAcceptClick)
    @el.off('click', '.request .ignore:not(.disabled)', @.onIgnoreClick)

  render: ->
    @.updateContent(
      if @requests
        @.renderTemplate('app_requests/list', @)
      else
        I18n.t('common.loading')
    )

    @el.find('.content').on('select.tab', @.onTabSelected).tabs()

  onDataLoad: (response)=>
    @loading = false

    @count = response.count
    @requests = response.requests

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

    @.hideRequestByControl(link)

    $.ajax(
      url: "/app_requests/ignore.json"
      type: 'PUT'
      data:
        ids: link.data('request-id')
    )

  onTabSelected: (e, tabs)=>
    tabs.current_container.find('img[data-src]').each ()->
      this.setAttribute('src', this.getAttribute('data-src'))
      this.removeAttribute('data-src')

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
    InviteDialogController.show('gift',
      dialog:
        to: ids
        title: I18n.t('app_requests.invites.gift.title', item: target.name)
        message: I18n.t('app_requests.invites.gift.message', item: target.name, app: I18n.t('app_name'))
        data:
          item: target.alias
    )

  countAll: ->
    total = 0

    for type, requests of @requests
      total += _.reduce(requests, ((sum, r)-> sum + (r.senders?.length || 1)), 0)

    total

  countByType: (type)->
    _.reduce(@requests[type], ((sum, r)-> sum + (r.senders?.length || 1)), 0)

  senderIds: (request)->
    _.map(request.senders, (s)-> s.facebook_id ).join(',')

  requestIds: (request)->
    _.map(request.senders, (s)-> s.request_id ).join(',')