class Character
  module Monsters
    def self.included(base)
      base.class_eval do
        has_many :monster_fights

        has_many :monsters,
          :through  => :monster_fights

        has_many :monster_types,
          :through  => :monsters,
          :extend   => MonsterTypeAssociationExtension
      end
    end

    module MonsterTypeAssociationExtension
      def available
        MonsterType.with_state(:visible).scoped(:conditions => ["level <= ?", proxy_owner.level])
      end
    end
  end
end