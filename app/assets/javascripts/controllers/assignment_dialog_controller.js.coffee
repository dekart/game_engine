#= require controllers/dialog_controller

window.AssignmentDialogController = class extends DialogController
  @show: (role)->
    @controller ?= new @()
    @controller.role = role
    @controller.show()

  className: 'dialog assignment'

  elements:
    '.relation' : 'relation_elements'
    'button.promote' : 'button'

  render: ->
    @html(
      @.dialogWrapper(@.renderTemplate('assignment_dialog', @))
    )

    @el.find('#assignment_tabs').tabs()

  show: ->
    @loading = true

    $.getJSON('/characters/current/assignments/new', {role: @role}, @.onDataLoad)

    super

  setupEventListeners: ->
    super

    @el.on('click', '.relation', @.onRelationClick)
    @el.on('click', 'button.promote:not(.disabled)', @.onPromoteButtonClick)

  unbindEventListeners: ->
    super

    @el.off('click', '.relation', @.onRelationClick)
    @el.off('click', 'button.promote:not(.disabled)', @.onPromoteButtonClick)

  onDataLoad: (response)=>
    @loading = false

    @relations = response

    @.render()

  onDataSave: (response)=>
    $('#assignments').html(response.content)

    _gaq?.push(['_trackEvent', 'Alliance', 'Promoted', @role])

    @.close()

  onRelationClick: (e)=>
    element = $(e.currentTarget)

    @selected = element.data('value')

    @relation_elements.removeClass('selected')
    element.addClass('selected')

    @button.removeClass('disabled')

  onPromoteButtonClick: (e)=>
    $.post('/characters/current/assignments',
      assignment:
        role: @role
        relation_id: @selected
      @.onDataSave
    )
