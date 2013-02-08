#= require controllers/base_controller

window.MonsterListController = class extends BaseController
  elements:
    '#finished_fights' : 'finished_fights_el'

  @show: ->
    @controller ?= new @()
    @controller.show()

  prepareHelpers: ->
    super(MonstersHelper)

  setupEventListeners: ->
    @.unbindEventListeners()

    @el.on('click', '#finished_fights', @.onFinishedFightsClick)
    @el.on('click', '.monster_list .engage, .monster_list .view, .monster_list .reward', @.onEngageClick)
    @el.on('click', '.monster_list .attack', @.onAttackClick)


  unbindEventListeners: ->
    @el.off('click', '#finished_fights', @.onFinishedFightsClick)
    @el.off('click', '.monster_list .engage, .monster_list .view, .monster_list .reward', @.onEngageClick)
    @el.off('click', '.monster_list .attack', @.onAttackClick)


  show: ->
    @loading = true

    transport.one('monsters_loaded', @.onDataLoad)
    transport.send('load_monsters')

    @.render()


  onDataLoad: (response)=>
    @loading = false

    @defeated = response.defeated
    @active   = response.active
    @locked   = response.locked
    @monster_types = response.monster_types

    @.render()


  render: ()->
    $('#page').empty().append(@el)

    if @loading
      @html(
        I18n.t('common.loading')
      )
    else
      @html(
        @.renderTemplate("monsters/list", @)
      )

      new VisualTimer(["#monster_#{fight.monster.id} .fight_time .value"]).start(fight.time_remaining) for fight in @active

      @.setupEventListeners()


  onFinishedFightsClick: (e)=>
    transport.one('finished_monsters_loaded', (response)=>
      @finished_fights_el.html(
        @.renderTemplate("monsters/preview/finished", _.extend({finished: response.finished}, @))
      )
    )
    transport.send('load_finished_monsters')


  onEngageClick: (e)=>
    id = $(e.currentTarget).data("id")

    MonsterController.load(id)


  onAttackClick: (e)=>
    id = $(e.currentTarget).data("id")

    MonsterController.create(id)
