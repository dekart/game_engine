#= require controllers/dialog_controller

window.MissionResultDialogController = class extends DialogController
  @show: (result)->
    @controller ?= new @()
    @controller.show(result)

  className: 'dialog mission_result'

  show: (result)->
    @result = result

    @mission = Mission.find(result.id)

    super

  render: ->
    @.updateContent(@.renderTemplate('missions/result', @))

  setupEventListeners: ->
    super

    @el.on('click', 'button.continue', @.onClientContinueButtonClick)

  unbindEventListeners: ->
    super

    @el.off('click', 'button.continue', @.onClientContinueButtonClick)

  onClientContinueButtonClick: =>
    @mission.perform()