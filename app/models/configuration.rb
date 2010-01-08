class Configuration < ActiveRecord::Base
  [
    :assignment_attack_bonus,
    :assignment_defence_bonus,
    :assignment_fight_damage_multiplier,
    :assignment_fight_damage_divider,
    :assignment_fight_income_multiplier,
    :assignment_fight_income_divider,
    :assignment_mission_energy_multiplier,
    :assignment_mission_energy_divider,
    :assignment_mission_income_multiplier,
    :assignment_mission_income_divider,

    :bank_deposit_fee,

    :character_attack_upgrade,
    :character_defence_upgrade,
    :character_health_upgrade,
    :character_energy_upgrade,

    :character_health_restore_period,
    :character_energy_restore_period,
    :character_income_calculation_period,
      
    :character_weakness_minimum,
    :character_points_per_upgrade,
    :character_vip_money_per_upgrade,

    :premium_money_price,
    :premium_money_amount,
    :premium_energy_price,
    :premium_health_price,
    :premium_points_price,
    :premium_points_amount,
    :premium_mercenary_price,

    :fight_victim_show_limit,
    :fight_victim_levels_lower,
    :fight_victim_levels_higher,
    :fight_attack_repeat_delay,
    :fight_energy_required,
    :fight_experience,
    :fight_money_loot,
    :fight_max_loser_damage,
    :fight_max_winner_damage,
    :fight_latest_show_limit,
    :fight_with_invite_energy_required,
    :fight_with_invite_max_level,
    :fight_with_invite_experience,
    :fight_with_invite_money_min,
    :fight_with_invite_money_max,
    :fight_with_invite_victim_damage_max,
    :fight_with_invite_victim_damage_min,
    :fight_with_invite_attacker_damage,

    :rating_show_limit,

    :help_request_expire_period,
    :help_request_display_period,
    :help_request_mission_money,
    :help_request_mission_experience,
    :help_request_fight_money,
    :help_request_fight_experience,

    :inventory_sell_price,

    :item_show_basic,
    :item_show_special,

    :property_sell_price,
    :property_maximum_amount,

    :user_invite_page_first_visit_delay,
    :user_invite_page_recurrent_visit_delay,

    :relation_show_limit,

    :newsletter_recipients_per_send,
    :newsletter_send_sleep,

    :boss_max_loser_damage,
    :boss_max_winner_damage
  ].each do |field|
    validates_presence_of field
    validates_numericality_of field
  end

  validates_presence_of :user_admins

  after_save :restart_server

  def self.[](key)
    first.send(key)
  end

  def self.current
    first
  end

  def boss_max_loser_damage
    50
  end

  def boss_max_winner_damage
    1
  end

  private

  def restart_server
    system("touch #{File.join(RAILS_ROOT, "tmp", "restart.txt")}")
  end
end
