class Character
  class Boosts
    def initialize(character)
      @character = character
    end

    def inventories
      @character.inventories.scoped(:joins => :item, :conditions => "boost_type != ''")
    end

    # TODO: remove
    def best_attacking
      inventories.select{|i| i.attack > 0 || i.health > 0 }.max_by{|i| [i.attack, i.health] }
    end

    def best_defending
      inventories.select{|i| i.defence > 0 || i.health > 0 }.max_by{|i| [i.defence, i.health] }
    end

    def best_energy
      inventories.select{|i| i.energy > 0 }.max_by{|i| i.energy }
    end
    
    def for(type, destination)
      send("for_#{type}_#{destination}")
    end
    
    def for_fight_damage
      by_type('fight').scoped(:conditions => ['items.attack > 0 OR items.health > 0'])
    end
    
    def for_fight_defence
      by_type('fight').scoped(:conditions => ['items.defence > 0'])
    end
    
    def for_monster_damage
      by_type('monster')
    end
    
    def by_type(boost_type)
      @character.inventories.scoped(:joins => :item, :conditions => {
        'items.boost_type' => boost_type.to_s
      })
    end
    
    def active_for(type, destination)
      boost_id = send("active_for_#{type}_#{destination}")
      @character.inventories.find(boost_id) if boost_id
    end
    
    def active_for_fight_damage
      @character.active_boosts[:fight][:damage] if @character.active_boosts[:fight]
    end
    
    def active_for_fight_defence
      @character.active_boosts[:fight][:defence] if @character.active_boosts[:fight]
    end
    
    def active_for_monster_damage
      @character.active_boosts[:monster][:damage] if @character.active_boosts[:monster]
    end
  end
end
