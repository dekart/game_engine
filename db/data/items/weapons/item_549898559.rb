
          GameData::Item.define :item_549898559 do |i|
            i.group = :weapons

            i.tags = [:gift]
            
        i.level = 3
      
      i.visible_if do |character|
        character.character_type.key == :warrior or character.character_type.key == :trader
      end
    
        i.placements = [:right_hand, :left_hand, :additional]
      
        i.basic_price = 40
      
        i.package_size = 1
      
          i.effects = {:attack=>1}
        
          end
        
