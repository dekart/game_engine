#= require controllers/refill_dialogs/refill_dialog_controller

window.EnergyRefillDialogController = class extends RefillDialogController
  className: 'dialog refill energy'

  refillAttribute: 'energy'

  render: ->
    @.updateContent(JST['views/refill_dialogs/energy'](@))
