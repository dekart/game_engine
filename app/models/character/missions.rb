class Character
  module Missions
    def self.included(base)
      base.class_eval do
        has_one :mission_state
      end
    end

    def missions
      (mission_state || create_mission_state).tap do |s|
        s.character = self
      end
    end
  end
end
