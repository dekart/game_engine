
          GameData::Mission.define :wild_centaurs do |m|
            
        m.group = :recruit
      
          m.level do |l|
            l.steps = 12
        
          l.chance = 60
        
        l.requires do |r|
          
            r.ep = 8
          
        end
      
      l.reward_on :success do |r|
        
              r.take_energy 8
              r.give_experience 12
              r.give_basic_money 50..100
            
      end
    
      l.reward_on :repeat_success do |r|
        
              r.take_energy 8
              r.give_experience 12
              r.give_basic_money 50..100
            
      end
    
      l.reward_on :failure do |r|
        
              r.take_energy 8
            
      end
    
      l.reward_on :repeat_failure do |r|
        
              r.take_energy 8
            
      end
    
          end
        
          end
        
