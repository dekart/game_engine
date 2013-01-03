
          GameData::Mission.define :thieves do |m|
            
        m.group = :tutorial
      
        m.tags = [:repeatable]
      
          m.level do |l|
            l.steps = 4
        
        l.requires do |r|
          
            r.ep = 2
          
        end
      
      l.reward_on :success do |r|
        
              r.take_energy 2
              r.give_experience 4
              r.give_basic_money 15..20
            
      end
    
      l.reward_on :repeat_success do |r|
        
              r.take_energy 2
              r.give_experience 4
              r.give_basic_money 15..20
            
      end
    
      l.reward_on :failure do |r|
        
              r.take_energy 2
            
      end
    
      l.reward_on :repeat_failure do |r|
        
              r.take_energy 2
            
      end
    
          end
        
          end
        
