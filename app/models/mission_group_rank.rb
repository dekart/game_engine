class MissionGroupRank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission_group

  named_scope :completed, {
    :conditions => {:completed => true},
    :include    => :mission_group,
    :order      => "mission_groups.level"
   }

  before_create :set_completed
  after_create  :apply_payouts, :assign_just_created

  delegate :title, :to => :mission_group

  attr_reader :payouts

  def completed?
    new_record? ? (missions_completed? && bosses_completed?) : self[:completed]
  end

  def just_created?
    @just_created
  end

  protected

  def missions_completed?
    (mission_group.mission_ids - character.missions.completed_ids).empty?
  end

  def bosses_completed?
    (mission_group.boss_ids - character.boss_fights.won_boss_ids).empty?
  end

  def set_completed
    self.completed = true
  end

  def apply_payouts
    @payouts = mission_group.payouts.apply(character, :complete)
  end

  def assign_just_created
    @just_created = true
  end
end