#= require controllers/base_controller

window.MonsterListController = class extends BaseController
  el: "#content_wrapper"

  constructor: ->
    super

    @.setupEventListeners()

  setupEventListeners: ->
    @el.on('click', '#finished_fights', @.onFinishedFightsClick)

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
