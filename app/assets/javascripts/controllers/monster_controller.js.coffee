#= require controllers/base_controller

window.MonsterController = class extends BaseController
  el: "#content_wrapper"

  constructor: ->
    super

    @.setupEventListeners()

  setupEventListeners: ->
    @el.on('click', '#monster .attack', @.onAttackClick)
    @el.on('click', '#monster .reward', @.onRewardClick)

  show: (id)->
    @loading = true

    $.getJSON("/monsters/#{id}", @.onDataLoad)

  onDataLoad: (response)=>
    @loading = false

    @monster = response.monster
    @fight   = response.fight

    @.render()

  render: ()->
    @html(
      @.renderTemplate("monster/monster", @)
    )

  onAttackClick: (e)=>
    id = @monster.id
    power_attack = $(e.currentTarget).data("power")

    $.ajax("/monsters/#{id}?power_attack=#{power_attack}", type: 'put', success: (response)=>
      alert "monster updated"
      @html(
        @.renderTemplate("monster/update", response: response)
      )
    )

  onRewardClick: (e)=>
    id = @monster.id

    $.post("/monsters/#{id}/reward", (response)=>
      result = @.renderTemplate("monster/reward", response: response)
      $('#result').html(result)

      monster_result = @.renderTemplate("monster/#{response.fight.monster.state}", 
        monster: response.fight.monster, fight: response.fight, percentage: 0, percentage_text: 0
      )
      $('#monster').html(monster_result)

      $(document).trigger('result.received')
    )
