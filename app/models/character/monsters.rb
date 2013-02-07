class Character
  module Monsters
    def self.included(base)
      base.class_eval do
        has_many :monster_fights,
          :extend     => MonsterFightsAssociationExtension,
          :dependent  => :delete_all

        has_many :monsters,
          :through  => :monster_fights
      end
    end

    module MonsterFightsAssociationExtension
      def redis_key(name)
        "character_#{proxy_association.owner.id}_#{name}_monster_fight_ids"
      end

      def add_to_active(fight)
        $redis.sadd(redis_key(:active), fight.id)
      end

      def add_to_defeated(fight)
        $redis.srem(redis_key(:active), fight.id)

        $redis.zadd(redis_key(:defeated), fight.monster.remove_at.to_i, fight.id)
      end

      def add_to_finished(fight)
        $redis.srem(redis_key(:active), fight.id)
        $redis.zrem(redis_key(:defeated), fight.id)

        $redis.zadd(redis_key(:finished), fight.monster.remove_at.to_i, fight.id)
      end

      def active
        where(:id => $redis.smembers(redis_key(:active))).joins(:monster).order('monsters.expire_at ASC')
      end

      def defeated
        $redis.zremrangebyscore(redis_key(:defeated), 0, Time.now.to_i)

        where(:id => $redis.zrange(redis_key(:defeated), 0, -1))
      end

      def finished
        $redis.zremrangebyscore(redis_key(:finished), 0, Time.now.to_i)

        where(:id => $redis.zrange(redis_key(:finished), 0, -1))
      end

      def current
        $redis.zremrangebyscore(redis_key(:defeated), 0, Time.now.to_i)
        $redis.zremrangebyscore(redis_key(:finished), 0, Time.now.to_i)

        ids = $redis.smembers(redis_key(:active)) +
          $redis.zrange(redis_key(:defeated), 0, -1) +
          $redis.zrange(redis_key(:finished), 0, -1)

        where(:id => ids)
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