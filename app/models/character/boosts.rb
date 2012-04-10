class Character
  class Boosts
    def initialize(character)
      @character = character
    end

    def inventories
      @character.inventories.boosts
    end
    
    def items
      @character.inventories.items.boosts
    end
    
    def by_item(item)
      @character.inventories.find_by_item(item) if item.boost?
    end

    def for(type, destination)
      by_type(type).select do |i| 
        i.item.boost_for?(type, destination)
      end
    end
    
    def by_type(boost_type)
      @character.inventories.by_boost_type(boost_type)
    end
    
    def active_for(type, destination) #returns inventory
      type = type.to_s
      destination = destination.to_s
      
      boost_id = @character.active_boosts[type][destination] if @character.active_boosts[type]
      
      @character.inventories.find_by_item_id(boost_id) if boost_id
    end

    def available_for_purchase(type, destination)
      owned_boosts_ids = @character.boosts.for(type, destination).collect{ |i| i.item_id }

      boosts = Item.purchaseable_for(@character).boosts(type)
      boosts = boosts.where(['items.id NOT IN(?)', owned_boosts_ids]) unless owned_boosts_ids.empty?

      boosts.select do |i|
        i.boost_for?(type, destination)
      end
    end
  end
end