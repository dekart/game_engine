#= require controllers/refill_dialogs/refill_dialog_controller

window.HealthRefillDialogController = class extends RefillDialogController
  className: 'dialog refill health'

  refillAttribute: 'health'

  render: ->
    @html(
      @.dialogWrapper(JST['views/refill_dialogs/health'](@))
    )
