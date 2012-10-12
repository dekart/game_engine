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
    '.health .hospital' : 'hospital'
    '.energy .refill' : 'refill_energy'
    '.stamina .refill' : 'refill_stamina'
    '.health .timer' : 'hp_timer_el'


  constructor: ->
    super

    @.setupTimers()
    @.setupEventListeners()

  setupEventListeners: ->
    Character.bind('save', @.onDataUpdate)

  setupTimers: ->
    @hp_timer = new VisualTimer(@hp_timer_el, @.onTimerFinish)
    @ep_timer = new VisualTimer(['#co .energy .timer'], @.onTimerFinish)
    @sp_timer = new VisualTimer(['#co .stamina .timer'], @.onTimerFinish)

  render: ()->
    character = Character.first()

    @basic_money.text(character.basic_money)
    @vip_money.text(character.basic_money)
    @experience.text(character.experience + "/" + character.next_level_experience)
    @experience_progress.css(width: "#{ character.experience / character.next_level_experience * 100}%")
    @health.text(character.hp + "/" + character.health_points)
    @energy.text(character.ep + "/" + character.energy_points)
    @stamina.text(character.sp + "/" + character.stamina_points)

    @hp_timer.start(character.time_to_hp_restore)
    @ep_timer.start(character.time_to_ep_restore)
    @sp_timer.start(character.time_to_sp_restore)

    @upgrade.toggle(character.points > 0)
    @hospital.toggle(character.hp < character.health_points / 2)
    @refill_energy.toggle(character.ep < character.energy_points / 2)
    @refill_stamina.toggle(character.sp < character.stamina_points / 2)


  onDataUpdate: =>
    @.render()

  onTimerFinish: =>
    Character.updateFromRemote()