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
        $.get("/monsters/#{@monster.id}/fighters", (response)=>
          @fighters = MonsterFighter.update(response.fighters)
          @.renderFighters() if @fighters.length > 0

          setTimeout(updateFighters, 20000)
        )
    setTimeout(updateFighters, 5000)

    updateMonster = ()=>
      if @monster.fighting()
        $.getJSON("/monsters/#{@monster.id}/status?rand=" + Math.random(), (response)=>
          @monster.updateAttributes(response)

          setTimeout(updateMonster, 20000)
        )
    setTimeout(updateMonster, 20000)

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


  onMonsterDataUpdate: ()=>
    if @monster.hp == 0
      @.render()
    else
      @.renderMonsterHealthUpdate()


  onFightDataUpdate: ()=>
    #@.renderImpact()


  renderMonsterHealthUpdate: ()=>
    @fight_el.find('.monster .health_bar .percentage').animate(
      { width: "#{ @monster.hp / @monster.health * 100 }%" },
      500
    )

    @fight_el.find('.monster .damage_bar .casting')
      .css({ width: '100%', opacity: 1 }).animate({ width: 0, opacity: 0 }, 800)
