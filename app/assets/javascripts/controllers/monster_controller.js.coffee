#= require controllers/base_controller

window.MonsterController = class extends BaseController
  el: "#monster"

  elements:
    '.fight'    : 'fight_el'
    '.leaders'  : 'leaders_el'

  @show: (id)->
    $.get("/monsters/#{id}", (response)=>
      $("#page").html(JST["views/monster/monster"])

      @controller = new @(response.monster, response.fight, response.fighters, response.leaders)
    )

  @create: (id)->
    $.get("/monsters/new?monster_type_id=#{id}", (response)=>
      $("#page").html(JST["views/monster/monster"])

      @controller = new @(response.monster, response.fight, response.fighters, response.leaders)
    )

  constructor: (monster_data, fight_data, fighters_data, leaders_data)->
    super

    @character = Character.first()
    @monster   = Monster.create(monster_data)
    @fight     = MonsterFight.create(fight_data)

    @fighters  = MonsterFighter.populate(fighters_data)
    @fighter_coords = MonsterFighter.coords()
    @leaders = leaders_data

    @.render()

    @.setupEventListeners()
    @.setupAutoUpdate()


  setupEventListeners: ->
    @.unbindEventListeners()

    Monster.bind('save', @.onMonsterDataUpdate)


  unbindEventListeners: ->
    Monster.unbind('save', @.onMonsterDataUpdate)


  setupAutoUpdate: ->
    updateLeaders = ()=>
      if @monster.fighting()
        $.get("/monsters/#{@monster.id}/leaders", (response)=>
          @leaders = response.leaders

          @.renderLeaders()

          setTimeout(updateLeaders, 60000)
        )
    setTimeout(updateLeaders, 60000)

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
    @.renderFight()
    @.renderLeaders()


  renderFight: ()=>
    @fight_el.html(
      @.renderTemplate('monster/fight', @)
    )
    @.renderActions()

    new VisualTimer([@fight_el.find('.fight_time .value')]).start(@monster.time_remaining)

    @fight_el.find('a.reward').click(@.onRewardClick)


  renderActions: ()=>
    @fight_el.find('.actions').html(
      @.renderTemplate('monster/actions', @)
    )

    @fight_el.find('.actions a').click(@.onActionClick)


  renderLeaders: ()=>
    @leaders_el.html(
      @.renderTemplate('monster/leaders', @)
    )


  renderMonsterHealthUpdate: ()=>
    @fight_el.find('.monster .damage_bar .text').html(
      "#{@monster.hp} / #{@monster.health}"
    )

    @fight_el.find('.monster .damage_bar .percentage').animate(
      { width: "#{ @monster.hp / @monster.health * 100 }%" },
      500
    )

    @fight_el.find('.monster .damage_bar .casting')
      .css({ width: '100%', opacity: 1 }).animate({ width: 0, opacity: 0 }, 800)


  renderMonsterDamage: (value)=>
    @fight_el.find('.monster .damage')
      .css({ top: '80px' }).text('-' + value).show()
      .animate({ top: '-=25' }, 500)
      .delay(100).fadeOut()


  renderDamage: (character_damage, monster_damage)=>
    @fight_el.find('.character .damage')
      .css({ top: '15px' }).text('-' + character_damage).show()
      .animate({ top: '-=25' }, 500)
      .delay(100).fadeOut()

    @fight_el.find('.monster .attack_damage')
      .css({ top: '80px' }).text('-' + monster_damage).show()
      .animate({ top: '-=25' }, 500)
      .delay(100).fadeOut()


  renderFighters: ()=>
    el = @fight_el.find('.fighters')

    selector = @fighters.map((fighter)-> "##{fighter.id}").reduce((left, right)-> left + ',' + right)
    el.find(selector).addClass('old')

    for fighter in @fighters
      if (fighter_el = $(el).find("##{fighter.id}")) && fighter_el.length > 0
        fighter_el.data('damage', fighter.damage)
      else
        if (old_el = $(el).find('.fighter:not(.old):first')) && old_el.length > 0
          old_el.attr('id', fighter.id)
            .addClass('old')
            .css({'background-image': "url(#{fighter.image_url()})"})
            .data('damage', fighter.damage)
        else
          indexes = []
          el.find('.fighter').each (ind, f)->
            indexes.push($(f).data('index'))

          index = [0..11].filter((i)-> indexes.indexOf(i) == -1)[0]
          index = 0 unless index

          el.append("<div class='old fighter' id='#{fighter.id}' \
            data-index='#{index}' data-damage='#{fighter.damage}' \
            style='left:#{@fighter_coords[index][0]}px; top:#{@fighter_coords[index][1]}px; \
              background-image: url(#{fighter.image_url()})'> \
          </div>")

    el.find('.fighter:not(.old)').remove()
    el.find('.fighter').removeClass('old')


    # animation
    $(document).clearQueue('fighter_attack')

    animation_delay = 20000 / @fighters.length - 1200

    @fight_el.find('.fighter').each (index, element)=>
      $(document).queue('fighter_attack', (next)=>
        @.renderMonsterDamage($(element).data('damage'))

        @fight_el.find('.fighter_attack')
          .css(left: "#{@fighter_coords[index][0] + 50}px", top: "#{@fighter_coords[index][1]}px")
          .attr('class', '').addClass('fighter_attack')
          .addClass($(element).data('spell')).show()
          .animate({ top: '100px', left: '400px' }, 500)
          .delay(100).fadeOut()
          .promise().done(next)
      )

      $(document).delay(animation_delay, 'fighter_attack')

    $(document).dequeue('fighter_attack')


  animateAction: (action_el)=>
    action_el = action_el.clone()
    action_el.find('span').remove()

    @fight_el.find('.character_attack')
      .html(action_el)
      .css({ left: '200px'}).show()
      .animate({ left: '+=140' }, 500)
      .delay(500).fadeOut()


  #callbacks
  onMonsterDataUpdate: ()=>
    if @monster.hp == 0
      @.render()
    else
      @.renderMonsterHealthUpdate()


  onActionClick: (e)=>
    e.preventDefault()

    link = if e.target.nodeName == "A" then $(e.target) else $(e.target).parent('a')

    @fight_el.find('.actions').addClass('locked')
    @fight_el.find('.actions a').unbind('click')

    $.post("/monsters/#{@monster.id}", {
        '_method': 'put',
        'boost': link.data('boost'),
        'power_attack': link.data('power')
      }, (response)=>
        if response.success
          @.onAttackSuccess(response, link)
        else
          if response.refill
            switch response.refill
              when 'refill_health'
                HealthRefillDialogController.show()
              when 'refill_stamina'
                StaminaRefillDialogController.show()

          @fight_el.find('.actions').removeClass('locked')
          @fight_el.find('.actions a').click(@.onActionClick)
    )


  onAttackSuccess: (data, action_link)=>
    Character.update(data.character)

    $(document).trigger('attack_success')

    $(document).queue('monster_fight', (next)=>
      @.renderDamage(data.character_damage, data.monster_damage)

      @.animateAction(action_link)

      @monster.updateAttributes(hp: Math.max(@monster.hp - data.monster_damage, 0))

      @fight.updateAttributes(
        damage: @fight.damage + data.monster_damage,
      )

      next()
    )

    $(document).delay(500, 'monster_fight')

    $(document).queue('monster_fight', (next)=>
      @fight_el.find('.actions').removeClass('locked')
      @fight_el.find('.actions a').click(@.onActionClick)

      next()
    )

    unless _.isEqual(data.boosts, @fight.boosts)
      $(document).queue('monster_fight', (next)=>
        @fight.updateAttributes(
          boosts: data.boosts
        )

        @.renderActions()

        next()
      )

    $(document).dequeue('monster_fight')


  onRewardClick: (e)=>
    e.preventDefault()

    button = $(e.currentTarget)
    button.addClass('disabled')

    unless @fight.reward_collected
      $.post("/monsters/#{@monster.id}/reward", {}, (response)=>
        button.parent().after(
          @.renderTemplate('monster/rewards', _.extend(@, { fight_rewards: response.rewards }))
        )

        button.remove()
      )
