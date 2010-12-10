class MissionRank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission

  before_save :cache_completion

  def completed?
    self[:completed] || levels_completed?
  end

  protected

  def levels_completed?
    mission.levels.size == character.mission_levels.completed_ids(mission).size
  end

  def cache_completion
    self.completed = levels_completed?

    true
  end
end
