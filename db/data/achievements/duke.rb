
          GameData::Achievement.define :duke do |c|
            
        a.condition do |character|
          character.total_money >= 100000
        end
      
      a.reward_on :achieve do |r|
    r.give_vip_money(4)

      end
    
          end
        
