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

  unbindEventListeners: ->
    super

    @el.off('click', 'button.continue:not(.disabled)', @.onClientContinueButtonClick)

  onClientContinueButtonClick: (e)=>
    $(e.currentTarget).addClass('disabled')

    @mission.perform()
