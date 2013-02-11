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

    # @el.on('click', '#mission_group_list .mission_group', @.onClientMissionGroupClick)
    # @el.on('click', '.mission button:not(.disabled)', @.onClientMissionButtonClick)

    # MissionGroup.bind('activated', @.onDataMissionGroupActivate)
    # Mission.bind('performed', @.onDataMissionPerform)

  unbindEventListeners: ->
    # @el.off('click', '#mission_group_list .mission_group', @.onClientMissionGroupClick)
    # @el.off('click', '.mission button:not(.disabled)', @.onClientMissionButtonClick)

    # MissionGroup.unbind('activated', @.onDataMissionGroupActivate)
    # Mission.unbind('performed', @.onDataMissionPerform)

  show: ()->
    @.setupEventListeners()

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

      # @.setupEventListeners()


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

  populateData: (response)->
    ItemGroup.set(response.groups)
    Item.set(_.find(response.groups, (g)-> g.current ), response.items)
