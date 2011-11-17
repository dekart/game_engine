module Event
  class UnlockMission < Base
    attr_accessor :mission_id
    
    delegate :state, :to => :mission
    
    def mission_id=(value)
      @mission_id = value.to_i
    end

    def mission
      @mission ||= ::Mission.find_by_id(mission_id)
    end

    def trigger!(character)
      Rails.logger.debug "Mission #{mission.name} unlocked"
    end
    
    def to_s
      "%s: %s (%d%% %s)" % [
        trigger_label,
        mission.name,
        chance
      ]
    end
  end
end
