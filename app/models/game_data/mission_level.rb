module GameData
  class MissionLevel < Base
    class << self
      def load!
        GameData::Mission.load!
      end
    end

    attr_accessor :mission, :steps, :chance
  end
end