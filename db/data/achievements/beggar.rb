
          GameData::Achievement.define :beggar do |a|
            
        a.condition do |character|
          character.total_money >= 500
        end
      
      a.reward_on :achieve do |r|
        r.give_vip_money(1)

      end
    
          end
        
