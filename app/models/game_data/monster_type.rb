module GameData
  class MonsterType < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/monsters/*.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    PICTURE_FORMATS = %w{small stream}

    attr_accessor :level, :fight_time, :respawn_time, :health, :damage, :response, :reward_collectors, :effects

    def initialize(key)
      super

      @effects = {}
    end

    def name
      I18n.t("data.monsters.#{ @key }.name")
    end

    def description
      I18n.t("data.monsters.#{ @key }.description", :default => '')
    end

    def visible?(character)
      super and (level.nil? or character.level > level)
    end

    def locked_for?(character)
      level and character.level < level
    end

    def average_damage
      (damage.end - damage.begin) / 2
    end

    def as_json(*args)
      super.merge!(
        :name         => name,
        :description  => description,
        :pictures     => pictures,
        :level        => level,
        :fight_time   => fight_time,
        :health       => health,
        :damage       => [damage.begin, damage.end],
        :multiplayer  => tags.include?(:multiplayer)
      )
    end

    def as_json_for(character)
      as_json.merge!(
        :requirements => requirements(character),
        :rewards => preview_reward_on(
          character.monsters.rewarded_monster_types.include?(self) ? :repeat_victory : :victory,
          character
        )
      )
    end
  end
end