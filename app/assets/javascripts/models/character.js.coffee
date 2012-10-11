window.Character = class extends Spine.Model
  @configure 'Character', 'basic_money', 'vip_money',
    'level', 'experience', 'next_level_experience', 'points',
    'energy_points', 'ep', 'time_to_ep_restore',
    'stamina_points', 'sp', 'time_to_sp_restore',
    'health_points', 'hp', 'time_to_hp_restore'

  @update: (values)->
    character = @first() || @create()

    character.updateAttributes(values)

  @updateFromRemote: ()->
    $.getJSON('/character_status/?rand=' + Math.random(), (response)=>
      @.update(response)
    )

