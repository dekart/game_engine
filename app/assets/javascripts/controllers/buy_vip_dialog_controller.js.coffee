#= require controllers/dialog_controller

window.BuyVipDialogController = class extends DialogController
  show: ()->
    @loading = true
    @packages = []

    $.getJSON("/premium/buy_vip", @.onDataLoad)

    super

  setupEventListeners: ->
    super

    @el.on('click', '.credit_package', @.onPackageSelect)
    @el.on('click', 'button.purchase', @.onPurchaseClick)
    @el.on('click', '.earn_credits', @.onEarnCreditsClick)

  unbindEventListeners: ->
    super

    @el.off('click', '.credit_package', @.onPackageSelect)
    @el.off('click', 'button.purchase', @.onPurchaseClick)
    @el.off('click', '.earn_credits', @.onEarnCreditsClick)

  onDataLoad: (response)=>
    @loading = false
    @packages = response.packages

    @.render()

  render: ->
    @.updateContent(JST['views/buy_vip'](@))

  onPackageSelect: (e)=>
    @el.find('.credit_package').removeClass('selected');

    $(e.currentTarget).addClass('selected').find(':radio').attr('checked', 'true');

  onPurchaseClick: (e)=>
    $(e.currentTarget).addClass('disabled')

    package_id = parseInt(@el.find('input:checked').val())

    FB.ui(
      {
        method: 'pay',
        action: 'purchaseitem',
        product: callback_location + '/credit_orders/' + package_id,
        request_id: Date.now() + ':' + Character.first().id + ':' + package_id
      },
      @.onPurchaseProcessed
    )

  onPurchaseProcessed: (response)=>
    if response.payment_id?
      $.post("/credit_orders?_method=post", response, @.onPurchaseResult)

  onPurchaseResult: (response)=>
    alert(I18n.t("premia.buy_vip.success", amount: response.vip_money))

    Character.updateFromRemote()

    @.close()

  onEarnCreditsClick: (e)=>
    FB.ui(
      {
        method: 'pay',
        credits_purchase: true,
        dev_purchase_params: {"shortcut":"offer"}
      },
      (response)=>
        true
    )
