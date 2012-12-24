
          GameData::CharacterType.define :trader do |c|
            
        c.attributes = {
          :attack => 1,
          :defence => 1,
          :health => 100,
          :energy => 10,
          :stamina => 10,
          :hp_restore_rate => 0,
          :ep_restore_rate => 0,
          :sp_restore_rate => 0,

          :equipment_slots => 5
        }
      
        c.reward_on :create do |r|
          r.give_basic_money 10
          r.give_vip_money 0
          r.give_upgrade_points 0
        end
      
          end
        
