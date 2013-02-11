#= require ./base_controller
#= require ./requirement_controller

window.ShopController = class extends BaseController
  @show: ()->
    @controller ?= new @()
    @controller.show()

  className: 'shop'

  prepareHelpers: ->
    super(ItemHelper)

  setupEventListeners: ->
    @.unbindEventListeners()

    @el.on('change', 'select.amount', @.onAmountSelectorChange)

    # @el.on('click', '#mission_group_list .mission_group', @.onClientMissionGroupClick)
    # @el.on('click', '.mission button:not(.disabled)', @.onClientMissionButtonClick)

    # MissionGroup.bind('activated', @.onDataMissionGroupActivate)
    # Mission.bind('performed', @.onDataMissionPerform)

  unbindEventListeners: ->
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

    @el.find("#item_group_#{ current_group.key }").html(
      @.renderTemplate('shop/item_list', @)
    )

  onAmountSelectorChange: (e)=>
    select_el = $(e.currentTarget)
    amount = select_el.val()
    item_el = select_el.parents('.item')
    item = Item.find(item_el.data('item-id'))

    if item.basic_price
      enough_basic_money = (Character.first().basic_money < item.basic_price * amount)

      item_el.find('.requires .basic_money')
        .text(item.basic_price * amount)
        .toggleClass('unsatisfied', enough_basic_money)
    else
      enough_basic_money = true

    if item.vip_price
      enough_vip_money = (Character.first().vip_money < item.vip_price * amount)

      item_el.find('.requires .vip_money')
        .text(item.vip_price * amount)
        .toggleClass('unsatisfied', enough_vip_money)
    else
      enough_vip_money = true

    item_el.find('button.buy').toggleClass('disabled', enough_basic_money and enough_vip_money)

  populateData: (response)->
    ItemGroup.set(response.groups)
    Item.set(_.find(response.groups, (g)-> g.current ), response.items)
