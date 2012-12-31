
          GameData::Mission.define :martial_tulnees do |m|
            
        m.group = :recruit
      
          m.level do |l|
            l.steps = 15
        
          l.chance = 70
        
        l.requires do |r|
          
            r.ep = 5
          
        end
      
      l.reward_on :success do |r|
        
              r.take_energy 5
              r.give_experience 5
              r.give_basic_money 35..60
            
      end
    
      l.reward_on :repeat_success do |r|
        
              r.take_energy 5
              r.give_experience 5
              r.give_basic_money 35..60
            
      end
    
      l.reward_on :failure do |r|
        
              r.take_energy 5
            
      end
    
      l.reward_on :repeat_failure do |r|
        
              r.take_energy 5
            
      end
    
          end
        
          end
        
