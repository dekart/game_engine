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

    $.getJSON('/monsters', @.onDataLoad)


  onDataLoad: (response)=>
    @loading = false

    @defeated = response.defeated
    @active   = response.active
    @locked   = response.locked
    @monster_types = response.monster_types

    console.log(response)

    @.render()


  render: ()->
    @html(
      @.renderTemplate("monsters/list", @)
    )

    $('#page').empty().append(@el)

    new VisualTimer(["#monster_#{fight.monster.id} .fight_time .value"]).start(fight.time_remaining) for fight in @active

    @.setupEventListeners()


  onFinishedFightsClick: (e)=>
    $.get("/monsters/finished", (response)=>
      @finished_fights_el.html(
        @.renderTemplate("monsters/finished", finished: response.finished)
      )
    )


  onEngageClick: (e)=>
    id = $(e.currentTarget).data("id")

    MonsterController.show(id)


  onAttackClick: (e)=>
    id = $(e.currentTarget).data("id")

    MonsterController.create(id)
