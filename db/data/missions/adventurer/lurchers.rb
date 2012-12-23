
          GameData::Mission.define :lurchers do |m|
            
        m.group = :adventurer
      
        m.tags = [:repeatable]
      
          m.level do |l|
            l.steps = 10
        
          l.chance = 60
        
      l.requires do |r|
        
            r.ep 2
          
      end
    
      l.reward_on :success do |r|
        
              r.take_energy 2
              r.give_experience 3
              r.give_basic_money 15..35
            
      end
    
      l.reward_on :repeat_success do |r|
        
              r.take_energy 2
              r.give_experience 3
              r.give_basic_money 15..35
            
      end
    
      l.reward_on :failure do |r|
        
              r.take_energy 2
            
      end
    
      l.reward_on :repeat_failure do |r|
        
              r.take_energy 2
            
      end
    
          end
        
          end
        
