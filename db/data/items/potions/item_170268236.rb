
          GameData::Item.define :item_170268236 do |i|
            i.group = :potions

            i.tags = [:shop]
            
        i.level = 2
      
        i.basic_price = 100
      
        i.package_size = 1
      
        i.sell_price = 50
      
      i.reward_on :use do |r|
        r.give_health(50)

      end
    
          end
        
