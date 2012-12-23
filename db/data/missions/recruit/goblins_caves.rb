
          GameData::Mission.define :goblins_caves do |m|
            
        m.group = :recruit
      
          m.level do |l|
            l.steps = 15
        
          l.chance = 70
        
      l.requires do |r|
        
            r.ep 4
          
      end
    
      l.reward_on :success do |r|
        
              r.take_energy 4
              r.give_experience 4
              r.give_basic_money 25..45
            
      end
    
      l.reward_on :repeat_success do |r|
        
              r.take_energy 4
              r.give_experience 4
              r.give_basic_money 25..45
            
      end
    
      l.reward_on :failure do |r|
        
              r.take_energy 4
            
      end
    
      l.reward_on :repeat_failure do |r|
        
              r.take_energy 4
            
      end
    
          end
        
          end
        
