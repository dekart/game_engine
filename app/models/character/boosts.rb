class Character
  class Boosts
    def initialize(character)
      @character = character
    end

    def inventories
      @character.inventories.scoped(:joins => :item, :conditions => "items.boost_type != ''")
    end

    def for(type, destination)
      send("for_#{type}_#{destination}")
    end
    
    def for_fight_attack
      by_type('fight').scoped(:conditions => ['items.attack > 0 OR items.health > 0'])
    end
    
    def for_fight_defence
      by_type('fight').scoped(:conditions => ['items.defence > 0'])
    end
    
    def for_monster_attack
      by_type('monster')
    end
    
    def by_type(boost_type)
      @character.inventories.scoped(:joins => :item, :conditions => {
        'items.boost_type' => boost_type
      })
    end
    
    def active_for(type, destination)
      boost_id = send("active_for_#{type}_#{destination}")
      @character.inventories.find_by_id(boost_id) if boost_id
    end
    
    def active_for_fight_attack
      @character.active_boosts['fight']['attack'] if @character.active_boosts['fight']
    end
    
    def active_for_fight_defence
      @character.active_boosts['fight']['defence'] if @character.active_boosts['fight']
    end
    
    def active_for_monster_attack
      @character.active_boosts['monster']['attack'] if @character.active_boosts['monster']
    end
  end
end