module GameData
  class MissionLevel < Base
    class << self
      def load!
        GameData::Mission.load!
      end
    end

    attr_accessor :mission, :steps, :chance

    def position
      @position ||= mission.levels.index(self)
    end

    def last?
      self == mission.levels.last
    end

    def chance
      @chance || 100
    end

    def as_json(*options)
      super.merge!(
        :position => position,
        :steps => steps
      )
    end

    def apply_reward_on(key, character, reward = nil)
      super(key, character, mission.apply_reward_on(key, character, reward))
    end

    def preview_reward_on(key, character, reward = nil)
      super(key, character, mission.preview_reward_on(key, character, reward))
    end
  end
end