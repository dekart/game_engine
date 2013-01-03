
          GameData::Item.define :item_552156825 do |i|
            i.group = :potions

            i.tags = [:shop]
            
        i.level = 2
      
        i.basic_price = 50
      
        i.vip_price = 5
      
        i.package_size = 1
      
        i.sell_price = 25
      
        i.max_market_price = 5
      
      i.reward_on :use do |r|
        r.give_upgrade_points(5)

      end
    
          end
        
