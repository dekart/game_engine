#= require ./base_controller
#= require ./requirement_controller

window.ShopController = class extends BaseController
  @show: ()->
    @controller ?= new @()
    @controller.show()

  className: 'shop'

  helpers: ->
    super(ItemHelper)

  setupEventListeners: ->
    @.unbindEventListeners()

    transport.bind('item_purchased', @.onItemPurchase)

    @el.on('change', 'select.amount', @.onAmountSelectorChange)
    @el.on('click', 'button.buy:not(.disabled)', @.onBuyButtonClick)
    # @el.on('click', '.mission button:not(.disabled)', @.onClientMissionButtonClick)

    # MissionGroup.bind('activated', @.onDataMissionGroupActivate)
    # Mission.bind('performed', @.onDataMissionPerform)

  unbindEventListeners: ->
    transport.unbind('item_purchased', @.onItemPurchase)

    @el.off('change', 'select.amount', @.onAmountSelectorChange)

    # @el.off('click', '#mission_group_list .mission_group', @.onClientMissionGroupClick)
    # @el.off('click', '.mission button:not(.disabled)', @.onClientMissionButtonClick)

    # MissionGroup.unbind('activated', @.onDataMissionGroupActivate)
    # Mission.unbind('performed', @.onDataMissionPerform)

  show: ()->
    @loading = true

    transport.one('shop_loaded', @.onDataLoad).send('load_shop')

    @.render()

  render: ->
    $('#page').empty().append(@el)

    if @loading
      @.renderPreloader()
    else
      @html(
        @.renderTemplate('shop/shop', @)
      )

      @el.find('#shop').tabs()
      @el.find('#shop').on('select.tab', @.onTabSelected)

      # @el.find('#mission_group_list').pageList()

    @.setupEventListeners()

  renderTab: (key)->
    @el.find("#item_group_#{ key }").html(
      @.renderTemplate('shop/item_list', @)
    )


  onDataLoad: (response)=>
    @loading = false

    @.populateData(response)

    @.render()

  onTabSelected: (e, tabs)=>
    tabs.current_container.html(
      I18n.t('common.loading')
    )

    transport.one('shop_loaded', @.onTabLoad).send('load_shop', tabs.current_tab.data('group-id'))

  onTabLoad: (response)=>
    @.populateData(response)

    current_group = ItemGroup.current()

    @.renderTab(current_group.key)

  onAmountSelectorChange: (e)=>
    select_el = $(e.currentTarget)
    amount = select_el.val()
    item_el = select_el.parents('.item')
    item = Item.find(item_el.data('item-id'))

    if item.basic_price
      item_el.find('.requires .basic_money')
        .text(item.basic_price * amount)
        .toggleClass('unsatisfied', not item.isEnoughBasicMoney(amount))

    if item.vip_price
      item_el.find('.requires .vip_money')
        .text(item.vip_price * amount)
        .toggleClass('unsatisfied', not item.isEnoughVipMoney(amount))

    item_el.find('button.buy').toggleClass('disabled', not item.isEnoughMoney(amount))

  onBuyButtonClick: (e)=>
    element = $(e.currentTarget).parents('.item')

    amount = element.find('select.amount').val()

    transport.send('buy_item', item_id: element.data('item-id'), amount: amount)

  onItemPurchase: (response)=>
    if response.success
      Character.update(response.character)

      item = Item.find(response.item.id)
      item.updateAttributes(response.item)

      @.renderTab(item.group().key)

      item_el = @el.find("#item_#{ response.item.key }")

      result_el = $(@.renderTemplate('shop/purchase_result', @, result: response)).appendTo('body')

      result_el.css(
        top: item_el.offset().top + (item_el.height() - result_el.height()) / 2
        left: ($('body').width() - result_el.width()) / 2
      )
        .animate(top: '-=100px', 700)
        .delay(700)
        .fadeOut(500, ()=> result_el.remove())

  populateData: (response)->
    ItemGroup.set(response.groups)
    Item.set(_.find(response.groups, (g)-> g.current ), response.items)
