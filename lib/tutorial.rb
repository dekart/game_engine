module Tutorial
  
  STEPS = [
    :hello_new_user,
    :complete_first_mission,
    :first_mission_receive,
    :first_mission_spent,
    :first_level_up,
    :first_upgrade_character,
    
    :goto_shop,
    :shop_buy_item,
    :goto_inventory,
    :goto_equip,
    :equip_character,
    
    :goto_monsters,
    :attack_monster,
    :attack_monster_first_time,
    :fight_with_monster_until_he_live,
    :monster_spent,
    :monster_die,
    
    :goto_estate,
    :buy_estate,
    :periodically_collect_property_income,

    :goto_fight,
    :attack_other_player,
    :fight_result,
    
    # :goto_alliance,
    
    :goto_gem_market,
    :spend_gems,
    :finish
    
  ]
  
  class << self
    
    def final_step?(step)
      STEPS.last == step.to_sym
    end
    
    def step_index(step)
      STEPS.index(step.to_sym)
    end
    
    def next_step(step)
      final_step?(step) ? "" : STEPS[step_index(step) + 1].to_s
    end
    
    def first_step
      STEPS.first.to_s
    end
    
    def first_step?(step)
      STEPS.first == step.to_sym
    end
    
  end
end