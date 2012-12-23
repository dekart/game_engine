module GameData
  class MissionLevel < Base
    attr_accessor :steps, :chance

    def initialize(mission, index)
      super("#{mission.key}_level_#{index}")

      @mission = mission
    end
  end
end