class Character
  class Boosts
    def initialize(character)
      @character = character
    end

    def inventories
      @character.inventories.scoped(:joins => :item, :conditions => "items.boost_type != ''")
    end

    def for(type, destination)
      by_type(type).select do |i| 
        i.item.boost_for?(type, destination)
      end
    end
    
    def by_type(boost_type)
      @character.inventories.scoped(:joins => :item, :conditions => {
        'items.boost_type' => boost_type.to_s
      })
    end
    
    def active_for(type, destination)
      type = type.to_s
      destination = destination.to_s
      
      boost_id = @character.active_boosts[type][destination] if @character.active_boosts[type]
      
      @character.inventories.find_by_id(boost_id) if boost_id
    end
    
    def not_owned(type, destination)
      inventory_boosts_ids = @character.boosts.for(type, destination).collect{ |i| i.item.id }
    
      boosts = Item.boosts(type)
      
      boosts = boosts.scoped(:conditions => ['id NOT IN(?)', inventory_boosts_ids]) unless inventory_boosts_ids.empty?
      
      boosts.select do |i|
        i.boost_for?(type, destination)
      end
    end
  end
end