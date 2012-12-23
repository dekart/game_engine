
          GameData::Achievement.define :lord do |a|
            
        a.condition do |character|
          character.total_money >= 10000
        end
      
      a.reward_on :achieve do |r|
        r.give_vip_money(3)

      end
    
          end
        
