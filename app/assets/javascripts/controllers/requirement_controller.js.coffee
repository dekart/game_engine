#=require_tree ./refill_dialogs

window.RequirementController = class extends DialogController
  @show: (requirements)->
    @controller ?= new @()

    for [type, name, value, satisfied, current_value] in requirements
      continue if satisfied

      switch type
        when 'attribute'
          switch name
            when 'ep'
              EnergyRefillDialogController.show()
            when 'hp'
              HealthRefillDialogController.show()
            when 'sp'
              StaminaRefillDialogController.show()
            else
              @controller.showAttribute(name, value)
        when 'item'
          @controller.showItem(name, value, current_value)

      break # Stop processing when reached first unsatisfied requirement

  showAttribute: (name, value)->
    @.show(@.renderTemplate('requirements/dialog_attribute', name: name, value: value))

  showItem: (item, value, current)->
    @.show(@.renderTemplate('requirements/dialog_item', item: item, value: value, current: current))

  setupEventListeners: ->
    super

    @el.on('click', 'button.buy_vip_money', @.onBuyVipMoneyButtonClick)
    @el.on('click', 'button.invite_friends', @.onInviteFriendsButtonClick)

  unbindEventListeners: ->
    super

    @el.off('click', 'button.buy_vip_money', @.onBuyVipMoneyButtonClick)
    @el.off('click', 'button.invite_friends', @.onInviteFriendsButtonClick)

  onBuyVipMoneyButtonClick: =>
    @.close()

    BuyVipDialogController.show()

  onInviteFriendsButtonClick: =>
    @.close()

    new InviteDialog('invitation'
      dialog:
        title: I18n.t('relations.invitation.title')
        message: I18n.t('relations.invitation.message', app_name: I18n.t('app_name'))
    )