
          GameData::ItemCollection.define :sample_collection do |c|
            
        c.items = {
          :item_97931052 => 1,
:item_549898559 => 1,
:item_6738267 => 1,
:item_349377643 => 1
        }
      
      c.reward_on :collected do |r|
        r.give_vip_money(5)
r.give_experience(50)

      end
    
      c.reward_on :repeat_collected do |r|
        r.give_experience(50)

      end
    
          end
        
