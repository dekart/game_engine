module Event
  class UnlockMission < Base
    delegate :state, :to => :item
    
    def mission=(value)
      @mission = value.is_a?(::Mission) ? value.id : value.to_i
    end

    def mission
      @mission ||= ::Mission.find_by_id(value)
    end

    def trigger!(character, reference = nil)
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
