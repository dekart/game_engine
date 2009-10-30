class Character
  module Missions
    def completed?(mission)
      completed_ids.include?(mission.id)
    end

    def completed_ids
      proxy_owner.ranks.all(:select => "mission_id", :conditions => {:completed => true}).collect{|m| m.mission_id}
    end
  end
end