#= require controllers/base_controller

window.MonsterListController = class extends BaseController
  el: "#content_wrapper"

  @show: ->
    @controller ?= new @()
    @controller.show()

  constructor: ->
    super

    @.setupEventListeners()

  setupEventListeners: ->
    @el.on('click', '#finished_fights', @.onFinishedFightsClick)
    @el.on('click', '.monster_list .engage, .monster_list .view, .monster_list .reward', @.onEngageClick)
    @el.on('click', '.monster_list .attack', @.onAttackClick)

  show: ->
    @loading = true

    $.getJSON('/monsters', @.onDataLoad)

  onDataLoad: (response)=>
    @loading = false

    @defeated = response.defeated
    @active   = response.active
    @locked   = response.locked
    @monster_types = response.monster_types

    @.render()

  render: ()->
    @html(
      @.renderTemplate("monsters/list", @)
    )

    new VisualTimer(["#monster_#{fight.monster.id} .fight_time .value"]).start(fight.time_remaining) for fight in @active

  onFinishedFightsClick: (e)=>
    $.get("/monsters/finished", (response)=>
      result = @.renderTemplate("monsters/finished", finished: response.finished)
    
      $('#finished_fights').html(result)
    )

  onEngageClick: (e)=>
    id = $(e.currentTarget).data("id")

    MonsterController.show(id)

  onAttackClick: (e)=>
    id = $(e.currentTarget).data("id")

    MonsterController.create(id)
