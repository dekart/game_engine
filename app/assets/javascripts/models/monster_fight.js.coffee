window.MonsterFight = class extends Spine.Model
  @configure 'MonsterFight', 'fight_id', 'damage', 'boosts',
    'power_attack_factor', 'reward_collected'

  action_tooltip: (boost, power_attack)->
    min_value = this.damage
    max_value = this.damage

    if power_attack
      min_value *= this.power_attack_factor
      max_value *= this.power_attack_factor

    boost_value = if boost > 0 then (' +' + boost) else ''

    I18n.t('monsters.fight.damage', { min: min_value, max: max_value, boost: boost_value })
