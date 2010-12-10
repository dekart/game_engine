class MissionGroupRank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission_group

  before_save :cache_completion
  after_create  :apply_payouts, :assign_just_created

  attr_reader :payouts

  def completed?
    self[:completed] || (missions_completed? && bosses_completed?)
  end

  def just_created?
    @just_created
  end

  protected

  def missions_completed?
    mission_group.missions.with_state(:visible).size <= character.missions.completed_ids.size # Less or equal because mission can be hidden after completion
  end

  def bosses_completed?
    mission_group.bosses.with_state(:visible).size <= character.boss_fights.won_boss_ids.size # Less or equal because boss can be hidden after completion
  end

  def cache_completion
    self.completed = missions_completed? && bosses_completed?

    true
  end

  def apply_payouts
    @payouts = mission_group.payouts.apply(character, :complete, mission_group)
  end

  def assign_just_created
    @just_created = true
  end
end
