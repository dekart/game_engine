
          GameData::Mission.define :baron_vagra_s_ring do |m|
            
        m.group = :recruit
      
          m.level do |l|
            l.steps = 12
        
          l.chance = 75
        
        l.requires do |r|
          
            r.ep = 4
          
        end
      
      l.reward_on :success do |r|
        
              r.take_energy 4
              r.give_experience 3
              r.give_basic_money 20..65
            
      end
    
      l.reward_on :repeat_success do |r|
        
              r.take_energy 4
              r.give_experience 3
              r.give_basic_money 20..65
            
      end
    
      l.reward_on :failure do |r|
        
              r.take_energy 4
            
      end
    
      l.reward_on :repeat_failure do |r|
        
              r.take_energy 4
            
      end
    
          end
        
          end
        
