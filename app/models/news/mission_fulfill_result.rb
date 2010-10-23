module News
  class MissionFulfillResult < Base
    def successfull?
      data[:success]
    end

    def completed?
      data[:completed]
    end

    def mission
      @mission || find_mission
    end

  protected
    def find_mission
      @mission = Mission.find(data[:mission_id])
    end
  end
end
