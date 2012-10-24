window.Character = class extends Spine.Model
  @configure 'Character', 'basic_money', 'vip_money', 'points',
    'level', 'experience', 'next_level_experience', 'level_progress_percentage',
    'energy_points', 'ep', 'time_to_ep_restore',
    'stamina_points', 'sp', 'time_to_sp_restore',
    'health_points', 'hp', 'time_to_hp_restore',
    'pending_notifications_count'

  @update: (values)->
    character = @first() || @create()

    character.updateAttributes(values)

  @updateFromRemote: ()->
    $.getJSON('/character_status/?rand=' + Math.random(), (response)=>
      @.update(response)
    )

