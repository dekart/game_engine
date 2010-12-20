class Character
  class Boosts
    def initialize(character)
      @character = character
    end

    def inventories
      @inventories ||= @character.inventories.all(:joins => :item, :conditions => "boost = 1")
    end

    def best_attacking
      inventories.max_by{|i| [i.attack, i.health] }
    end

    def best_defending
      inventories.max_by{|i| [i.defence, i.health] }
    end
  end
end
