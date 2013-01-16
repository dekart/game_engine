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

    @el.on('click', '.invitation button', @.onAcceptClick)
    @el.on('click', '.gift button', @.onAcceptClick)
    @el.on('click', '.monster_invite button', @.onAcceptClick)
    @el.on('click', '.clan_invite button', @.onAcceptClick)

    @el.on('click', '.ignore', @.onIgnoreClick)

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

  onAcceptClick: (e)=>
    e.preventDefault()

    button = $(e.currentTarget)

    button.addClass('disabled')

    $.ajax(
      url: "/app_requests/#{ button.data('request-id') }.json"
      type: 'PUT'
      success: (r)=>
        @.processAcceptResponse(r)
        @.hideRequestByControl(button)
    )

  onIgnoreClick: (e)=>
    e.preventDefault()

    link = $(e.currentTarget)

    link.addClass('disabled')

    $.ajax(
      url: "/app_requests/#{ link.data('request-id') }/ignore.json"
      type: 'PUT'
      success: (r)=>
        @.hideRequestByControl(link)
    )

  processAcceptResponse: (response)->
    if response.next_page
      redirectTo(response.next_page)

  hideRequestByControl: (b)->
    b.parents('.request').fadeOut()