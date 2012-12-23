
          GameData::Achievement.define :merchant do |a|
            
        a.condition do |character|
          character.total_money >= 2000
        end
      
      a.reward_on :achieve do |r|
        r.give_vip_money(2)

      end
    
          end
        
