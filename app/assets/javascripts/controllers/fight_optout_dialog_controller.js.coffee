#= require controllers/dialog_controller

window.FightOptoutDialogController = class extends DialogController
  @show: ->
    @controller ?= new @()
    @controller.show()

  className: 'dialog fight_optout'

  render: ->
    @html(
      @.dialogWrapper(JST['views/fight_optout_dialog'](@))
    )

    @.updateOptinTimer()

  show: ->
    @loading = true

    $.getJSON('/fights/optout', @.onDataLoad)

    super

  setupEventListeners: ->
    super

    @el.on('click', 'button.save:not(.disabled)', @.onSaveButtonClick)
    @el.on('click', 'button.close', @.onCloseButtonClick)

  unbindEventListeners: ->
    super

    @el.off('click', 'button.save:not(.disabled)', @.onSaveButtonClick)
    @el.off('click', 'button.close', @.onCloseButtonClick)

  onDataLoad: (response)=>
    @loading = false

    @status = response

    @.render()

  onDataSave: =>
    redirectTo('/fights/new')

  onSaveButtonClick: (e)=>
    $.post(
      '/fights/optout'
      optout: @el.find('#fight_optout').prop('checked')
      @.onDataSave
    )

  onCloseButtonClick: (e)=>
    @.close()

  updateOptinTimer: =>
    if @status? and @status.next_change_in > 0
      @optin_timer ?= new VisualTimer(['#fight_optin_timer', @el])
      @optin_timer.start(@status.next_change_in)