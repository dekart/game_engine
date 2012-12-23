
          GameData::Mission.define :swamp_dragonflies do |m|
            
        m.group = :recruit
      
          m.level do |l|
            l.steps = 5
        
          l.chance = 60
        
      l.requires do |r|
        
            r.ep 6
          
      end
    
      l.reward_on :success do |r|
        
              r.take_energy 6
              r.give_experience 8
              r.give_basic_money 40..70
            
      end
    
      l.reward_on :repeat_success do |r|
        
              r.take_energy 6
              r.give_experience 8
              r.give_basic_money 40..70
            
      end
    
      l.reward_on :failure do |r|
        
              r.take_energy 6
            
      end
    
      l.reward_on :repeat_failure do |r|
        
              r.take_energy 6
            
      end
    
          end
        
          end
        
