
          GameData::ItemCollection.define :sample_collection do |c|
            
        c.items = {
          :item_169322587 => 1,
:item_278908225 => 1,
:item_708105219 => 1,
:item_170268236 => 1
        }
      
      c.reward_on :collected do |r|
        r.give_vip_money(5)
r.give_experience(50)

      end
    
      c.reward_on :repeat_collected do |r|
        r.give_experience(50)

      end
    
          end
        
