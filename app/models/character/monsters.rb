class Character
  module Monsters
    def self.included(base)
      base.class_eval do
        has_many :monster_fights,
          :dependent  => :delete_all
      end
    end

    class State
      def initialize(character)
        @character = character
      end

      def locked_monster_types
        GameData::MonsterType.select{|t| t.locked_for?(@character) }.sort_by{|t| t.level.to_i }
      end

      def available_monster_types
        GameData::MonsterType.select{|t| t.visible?(@character) } -
        GameData::MonsterType[recent_fights.own.pluck("monsters.monster_type_id")]
      end

      def active_fights
        fights_by_ids(
          $redis.smembers(fight_storage_key(:active))
        )
      end

      def defeated_fights
        fights_by_ids(
          $redis.zrangebyscore(fight_storage_key(:defeated), Time.now.to_i, '+inf')
        )
      end

      def finished_fights
        fights_by_ids(
          $redis.zrangebyscore(fight_storage_key(:finished), Time.now.to_i, '+inf')
        )
      end

      def recent_fights
        $redis.zremrangebyscore(fight_storage_key(:defeated), 0, Time.now.to_i)
        $redis.zremrangebyscore(fight_storage_key(:finished), 0, Time.now.to_i)

        fights_by_ids(
          $redis.smembers(fight_storage_key(:active)) +
          $redis.zrange(fight_storage_key(:defeated), 0, -1) +
          $redis.zrange(fight_storage_key(:finished), 0, -1)
        )
      end

      def add_to_active_fights(fight)
        $redis.sadd(fight_storage_key(:active), fight.id)
      end

      def add_to_defeated_fights(fight)
        $redis.srem(fight_storage_key(:active), fight.id)

        $redis.zadd(fight_storage_key(:defeated), fight.monster.remove_at.to_i, fight.id)
      end

      def add_to_finished_fights(fight)
        $redis.srem(fight_storage_key(:active), fight.id)
        $redis.zrem(fight_storage_key(:defeated), fight.id)

        $redis.zadd(fight_storage_key(:finished), fight.monster.remove_at.to_i, fight.id)
      end

      def recent_monster_types
        GameData::MonsterType[recent_fights.pluck('monsters.monster_type_id')]
      end

      def reward_collected!(fight)
        $redis.hincrby(reward_storage_key, fight.monster_type.key, 1)
      end

      def rewarded_monster_types
        GameData::MonsterType[$redis.hkeys(reward_storage_key)]
      end

      def [](monster_id)
        ::Monster.joins(:monster_fights).where("monsters.id = ? AND monster_fights.character_id = ?", monster_id, @character.id).first
      end

      private

      def fights_by_ids(ids)
        @character.monster_fights.joins(:monster).order('monsters.expire_at ASC').where("monster_fights.id IN (?)", ids)
      end

      def fight_storage_key(state)
        "character_#{ @character.id }_#{ state }_monster_fight_ids"
      end

      def reward_storage_key
        "character_#{ @character.id }_monster_rewards"
      end
    end

    def monsters
      @monters ||= State.new(self)
    end
  end
end