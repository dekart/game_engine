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
      class CollectedMonsterTypes
        def initialize(character)
          @character = character
        end
        
        def cache_key
          "character_#{ @character.id }_collected_monster_types"
        end

        def ids
          @ids ||= Rails.cache.fetch(cache_key) do
            @character.class.connection.select_values(
              @character.class.send(:sanitize_sql, 
                [
                  %{
                    SELECT DISTINCT monsters.monster_type_id
                    FROM monsters
                    INNER JOIN monster_fights ON (monster_fights.monster_id = monsters.id)
                    WHERE monster_fights.character_id = ? AND monster_fights.reward_collected = ?
                  }, 
                  @character.id, true
                ]
              )
            ).map{|id| id.to_i }
          end
        end
        
        def clear_cache!
          Rails.cache.delete(cache_key)
        end
      end
      
      def available_for_fight
        scope = MonsterType.with_state(:visible).where(["level <= ?", proxy_association.owner.level])

        if exclude_ids = proxy_association.owner.monster_fights.own.current.collect{|m| m.monster.monster_type_id }.uniq and exclude_ids.any?
          scope = scope.where(["id NOT IN (?)", exclude_ids])
        end

        scope
      end
      
      def available_in_future
        MonsterType.with_state(:visible).where(["level > ?", proxy_association.owner.level]).order(:level)
      end
      
      
      def collected
        @collected ||= CollectedMonsterTypes.new(proxy_association.owner)
      end
      
      def payout_triggers(type)
        collected.ids.include?(type.id) ? [:repeat_victory] : [:victory]
      end
    end
  end
end