class Character
  module Monsters
    def self.included(base)
      base.class_eval do
        has_many :monster_fights

        has_many :monsters,
          :through  => :monster_fights,
          :extend   => MonsterAssociationExtension
          
        has_many :monster_types,
          :through  => :monsters,
          :extend   => MonsterTypeAssociationExtension
      end
    end


    module MonsterTypeAssociationExtension
      def available_for_fight
        scope = MonsterType.with_state(:visible).scoped(:conditions => ["level <= ?", proxy_owner.level])

        if exclude_ids = proxy_owner.monsters.own.current.collect{|m| m.monster_type_id } and exclude_ids.any?
          scope = scope.scoped(:conditions => ["id NOT IN (?)", exclude_ids])
        end

        scope
      end
      
      def available_in_future
        MonsterType.with_state(:visible).scoped(
          :conditions => ["level > ?", proxy_owner.level], 
          :order => :level)
      end
    end
    
    
    module MonsterAssociationExtension
      def own
        scoped(:conditions => 'monsters.character_id = monster_fights.character_id')
      end
    end
  end
end