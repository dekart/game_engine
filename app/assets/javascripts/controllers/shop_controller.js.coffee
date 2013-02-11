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
    @loading = true

    transport.one('shop_loaded', @.onDataLoad).send('load_shop')

    @.render()

  render: ->
    $('#page').empty().append(@el)

    if @loading
      @.renderPreloader()
    else
      @html(
        @.renderTemplate('shop/list', @)
      )

      @el.find('#shop').on('select.tab', @.onTabSelected).tabs()

      # @el.find('#mission_group_list').pageList()

      # @.setupEventListeners()


  onDataLoad: (response)=>
    @loading = false

    ItemGroup.set(response.groups)
    Item.set(response.items)

    @.render()

  onTabSelected: (e, tabs)=>
    tab.current_container.html(
      I18n.js('common.loading')
    )

    tabs.current_tab.data('group-id')