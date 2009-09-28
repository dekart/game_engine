class Character
  module Ranks
    def completed_mission_ids
      find(:all, :select => "mission_id", :conditions => {:completed => true}).collect{|m| m.mission_id}
    end
  end
end