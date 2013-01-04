#= require controllers/dialog_controller

window.MissionResultDialogController = class extends DialogController
  @show: (result)->
    @controller ?= new @()
    @controller.show(result)

  className: 'dialog mission_result'

  show: (result)->
    @result = result

    @mission = Mission.find(result.mission.id)

    super

  render: ->
    @.updateContent(@.renderTemplate('missions/result', @))

  prepareHelpers: ->
    super

    _.extend(@helpers, MissionHelper)

  setupEventListeners: ->
    super

    @el.on('click', 'button.continue:not(.disabled)', @.onClientContinueButtonClick)
    @el.on('click', 'button.request_help:not(.disabled)', @.onClientRequestHelpButtonClick)

  unbindEventListeners: ->
    super

    @el.off('click', 'button.continue:not(.disabled)', @.onClientContinueButtonClick)
    @el.off('click', 'button.request_help:not(.disabled)', @.onClientRequestHelpButtonClick)

  onClientContinueButtonClick: (e)=>
    $(e.currentTarget).addClass('disabled')

    @mission.perform()

  onClientRequestHelpButtonClick: (e)=>
    StreamDialog.prepare('mission_help', mission_id: @mission.id)