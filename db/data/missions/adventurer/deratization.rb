
          GameData::Mission.define :deratization do |m|
            
        m.group = :adventurer
      
        m.tags = [:repeatable]
      
        m.requires do |r|
          r.item = [:item_169322587]

        end
      
          m.level do |l|
            l.steps = 20
        
        l.requires do |r|
          
            r.ep = 1
          
        end
      
      l.reward_on :success do |r|
        
              r.take_energy 1
              r.give_experience 2
              r.give_basic_money 8..15
            
      end
    
      l.reward_on :repeat_success do |r|
        
              r.take_energy 1
              r.give_experience 2
              r.give_basic_money 8..15
            
      end
    
      l.reward_on :failure do |r|
        
              r.take_energy 1
            
      end
    
      l.reward_on :repeat_failure do |r|
        
              r.take_energy 1
            
      end
    
          end
        
          end
        
