class MissionGroupRank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission_group

  before_save   :cache_completion
  after_create  :assign_just_completed

  def completed?
    self[:completed] || missions_completed?
  end

  def just_completed?
    @just_completed
  end

  protected

  def missions_completed?
    mission_group.missions.with_state(:visible).size <= character.missions.completed_ids(mission_group).size # Less or equal because mission can be hidden after completion
  end

  def cache_completion
    self.completed = missions_completed?

    true
  end

  def assign_just_completed
    @just_completed = true
  end
end
