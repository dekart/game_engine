#= require controllers/refill_dialogs/refill_dialog_controller

window.StaminaRefillDialogController = class extends RefillDialogController
  className: 'dialog refill stamina'

  refillAttribute: 'stamina'

  render: ->
    @html(
      @.dialogWrapper(JST['views/refill_dialogs/stamina'](@))
    )
