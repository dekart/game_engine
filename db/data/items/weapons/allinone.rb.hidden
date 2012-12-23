
          GameData::Item.define :allinone do |i|
            i.group = :weapons

            i.tags = [:shop, :market, :exchange]
            
        i.min_level = 5
      
        i.placements = [:right_hand, :left_hand]
      
        i.basic_price = 5
      
        i.vip_price = 5
      
        i.package_size = 10
      
        i.max_market_price = 5
      
          i.effects = {:attack=>5, :defence=>5}
        
      i.reward_on :use do |r|
    r.increase_attribute(:attack, 1) if Dice.chance(10) 
r.give_upgrade_points(1)
r.increase_attribute(:defence, 1)
r.give_energy(1)
r.give_experience(1)
r.give_vip_money(1)
r.give_health(1)
r.give_item(:item_6738267, 1)
r.give_mercenaries(1)
r.give_basic_money(1)
r.give_stamina(1)
r.increase_attribute(:energy, 1)
r.increase_attribute(:health, 1)
r.increase_attribute(:stamina, 1)
r.give_random_item(:mega_set, true)

      end
    
      i.reward_preview_on :use do |r|
        r.increase_attribute(:attack, 1)
r.give_upgrade_points(1)
r.increase_attribute(:defence, 1)
r.give_energy(1)
r.give_experience(1)
r.give_vip_money(1)
r.give_health(1)
r.give_item(:item_6738267, 1)
r.give_mercenaries(1)
r.give_basic_money(1)
r.give_stamina(1)
r.increase_attribute(:energy, 1)
r.increase_attribute(:health, 1)
r.increase_attribute(:stamina, 1)
r.give_random_item(:mega_set, true)

      end
    
          end
        
