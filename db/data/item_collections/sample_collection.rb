
          GameData::ItemCollection.define :sample_collection do |c|
            
        c.items = {
          :item_521700085 => 1,
:item_44753946 => 1,
:item_320799325 => 1,
:item_724365491 => 1
        }
      
      c.reward_on :collected do |r|
        r.give_vip_money(5)
r.give_experience(50)

      end
    
      c.reward_on :repeat_collected do |r|
        r.give_experience(50)

      end
    
          end
        
