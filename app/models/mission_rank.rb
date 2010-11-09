class MissionRank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission

  before_save :cache_completion

  def completed?
    self[:completed] || levels_completed?
  end

  protected

  def levels_completed?
    (mission.level_ids - character.mission_levels.completed_ids(mission)).empty?
  end

  def cache_completion
    self.completed = levels_completed?

    true
  end
end
