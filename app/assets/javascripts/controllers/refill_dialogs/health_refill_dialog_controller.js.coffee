#= require controllers/refill_dialogs/refill_dialog_controller

window.HealthRefillDialogController = class extends RefillDialogController
  className: 'dialog refill health'

  refillAttribute: 'health'

  render: ->
    @.updateContent(JST['views/refill_dialogs/health'](@))
