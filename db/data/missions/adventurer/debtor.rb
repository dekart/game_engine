
          GameData::Mission.define :debtor do |m|
            
        m.group = :adventurer
      
          m.level do |l|
            l.steps = 10
        
          l.chance = 70
        
        l.requires do |r|
          
            r.ep 4
          
        end
      
      l.reward_on :success do |r|
        
              r.take_energy 4
              r.give_experience 3
              r.give_basic_money 20..55
            
      end
    
      l.reward_on :repeat_success do |r|
        
              r.take_energy 4
              r.give_experience 3
              r.give_basic_money 20..55
            
      end
    
      l.reward_on :failure do |r|
        
              r.take_energy 4
            
      end
    
      l.reward_on :repeat_failure do |r|
        
              r.take_energy 4
            
      end
    
          end
        
          end
        
