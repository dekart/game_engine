
          GameData::Mission.define :orcs_in_iza do |m|
            
        m.group = :adventurer
      
          m.level do |l|
            l.steps = 15
        
          l.chance = 70
        
        l.requires do |r|
          
            r.ep 6
          
        end
      
      l.reward_on :success do |r|
        
              r.take_energy 6
              r.give_experience 8
              r.give_basic_money 30..60
            
      end
    
      l.reward_on :repeat_success do |r|
        
              r.take_energy 6
              r.give_experience 8
              r.give_basic_money 30..60
            
      end
    
      l.reward_on :failure do |r|
        
              r.take_energy 6
            
      end
    
      l.reward_on :repeat_failure do |r|
        
              r.take_energy 6
            
      end
    
          end
        
          end
        
