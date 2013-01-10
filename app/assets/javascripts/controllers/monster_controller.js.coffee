#= require controllers/base_controller

window.MonsterController = class extends BaseController
  el: "#content_wrapper"

  elements:
    '.fight'    : 'fight_el'
    '.impact'   : 'impact_el'
    '.fighters' : 'fighters_el'

  constructor: (monster_data, fight_data, fighters_data)->
    super

    @character = Character.first()
    @monster   = Monster.create(monster_data)
    @fight     = MonsterFight.create(fight_data)
    @fighters  = MonsterFighter.populate(fighters_data)
    @fighter_coords = MonsterFighter.coords()

    @.render()

    @.setupEventListeners()
    @.setupAutoUpdate()

  setupEventListeners: ->
    Monster.bind('save', @.onMonsterDataUpdate)
    MonsterFight.bind('save', @.onFightDataUpdate)

  setupAutoUpdate: ->
    updateFighters = ()=>
      if @monster.fighting()
        $.get("/monsters/#{@monster.monster_id}/fighters", (response)=>
          @fighters = MonsterFighter.update(response.fighters)
          @.renderFighters() if @fighters.length > 0

          setTimeout(updateFighters, 20000)
        )
    setTimeout(updateFighters, 5000)

    updateMonster = ()=>
      if @monster.fighting()
        $.getJSON("/monsters/#{@monster.monster_id}/status?rand=" + Math.random(), (response)=>
          @monster.updateAttributes(response)

          setTimeout(updateMonster, 20000)
        )
    setTimeout(updateMonster, 20000)

  #show: (id)->
  #  @loading = true
  #  $.getJSON("/monsters/#{id}", @.onDataLoad)

  #onDataLoad: (response)=>
  #  @loading = false
  #  @monster = Monster.create(response.monster)
  #  @fight   = MonsterFight.create(response.fight)
  #  @fighters = MonsterFighter.populate(response.fighters)
  #  @.render()

  render: ()->
    @html(
      @.renderTemplate("monster/monster", @)
    )

    @.renderFight()
    #@.renderImpact()
    #@.renderFighters()

  renderFight: ()=>
    @fight_el.html(
      @.renderTemplate('monster/fight', @)
    )
    @.renderActions()

    new VisualTimer([@fight_el.find('.fight_time .value')]).start(@monster.time_remaining)

    @fight_el.find('button.reward').click(@.onRewardClick)


  renderActions: ()=>
    @fight_el.find('.actions').html(
      @.renderTemplate('monster/actions', @)
    )

    @fight_el.find('.actions a').click(@.onActionClick)


  renderImpact: ()=>
    @impact_el.html(
      @.renderTemplate('monster/impact', @)
    )


  renderFighters: ()=>
    @fighters_el.html(
      @.renderTemplate('monster/fighters', @)
    )

  ##############################
  onMonsterDataUpdate: ()=>
    if @monster.hp == 0
      @.render()
    else
      @.renderMonsterHealthUpdate()


  onFightDataUpdate: ()=>
    @.renderImpact()

  ##############################
  onAttackClick: (e)=>
    id = @monster.id
    power_attack = $(e.currentTarget).data("power")

    $.ajax("/monsters/#{id}?power_attack=#{power_attack}", type: 'put', success: (response)=>
      result = @.renderTemplate("monster/update", response: response)
      $('#result').html(result)

      monster_result = @.renderTemplate("monster/#{response.fight.monster.state}", 
        monster: response.fight.monster, fight: response.fight, percentage: 0, percentage_text: 0
      )
      $('#monster').html(monster_result)

      $(document).trigger('result.received')

      Character.updateFromRemote()
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

      Character.updateFromRemote()
    )
