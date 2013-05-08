window.CharacterOverviewController = class extends Spine.Controller
  el: '#co'

  elements:
    '.basic_money .value' : 'basic_money'
    '.vip_money .value' : 'vip_money'
    '.experience .value' : 'experience'
    '.experience .percentage' : 'experience_progress'
    '.level .value' : 'level'
    '.health .value' : 'health'
    '.energy .value' : 'energy'
    '.stamina .value' : 'stamina'
    '.level .upgrade' : 'upgrade'
    '.health .refill' : 'refill_health'
    '.energy .refill' : 'refill_energy'
    '.stamina .refill' : 'refill_stamina'


  constructor: ->
    super

    @.setupTimers()
    @.setupEventListeners()

  setupEventListeners: ->
    Character.bind('save', @.onDataUpdate)

    @upgrade.click(@.onUpgradeClick)

    @el.on('click', 'a.refill', @.onRefillClick)
    @el.on('click', '.vip_money a.buy', @.onBuyVipClick)

  setupTimers: ->
    @hp_timer = new VisualTimer(['#co .health .timer'], @.onTimerFinish)
    @ep_timer = new VisualTimer(['#co .energy .timer'], @.onTimerFinish)
    @sp_timer = new VisualTimer(['#co .stamina .timer'], @.onTimerFinish)

  render: ()->
    character = Character.first()

    @basic_money.text(character.basic_money)
    @vip_money.text(character.vip_money)
    @experience.text(character.experience + "/" + character.next_level_experience)
    @experience_progress.css(width: "#{ character.level_progress_percentage }%")
    @level.text(character.level)
    @health.text(character.hp + "/" + character.health_points)
    @energy.text(character.ep + "/" + character.energy_points)
    @stamina.text(character.sp + "/" + character.stamina_points)

    @hp_timer.start(character.time_to_hp_restore)
    @ep_timer.start(character.time_to_ep_restore)
    @sp_timer.start(character.time_to_sp_restore)

    @upgrade.toggle(character.points > 0)
    @refill_health.toggle(character.hp < character.health_points / 2)
    @refill_energy.toggle(character.ep < character.energy_points / 2)
    @refill_stamina.toggle(character.sp < character.stamina_points / 2)

    if character.notifications_count > 0
      $.getScript('/notifications')

  onDataUpdate: =>
    @.render()

  onTimerFinish: =>
    Character.updateFromRemote()

  onUpgradeClick: (e)=>
    e.preventDefault()

    UpgradeDialogController.show()

  onRefillClick: (e)=>
    switch $(e.currentTarget).data('type')
      when 'health'
        HealthRefillDialogController.show()
      when 'energy'
        EnergyRefillDialogController.show()
      when 'stamina'
        StaminaRefillDialogController.show()

  onBuyVipClick: (e)=>
    e.preventDefault()

    BuyVipDialogController.show()
