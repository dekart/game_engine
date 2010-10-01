class MissionRank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission

  before_save :check_progress

  def completed?
    new_record? ? levels_completed? : self[:completed]
  end
  
  protected

  def levels_completed?
    (mission.level_ids - character.mission_levels.completed_ids(mission)).empty?
  end

  def check_progress
    self.completed = levels_completed?
    
    true
  end
end
