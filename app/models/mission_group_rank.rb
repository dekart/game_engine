class MissionGroupRank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission_group

  named_scope :completed, {
    :conditions => {:completed => true},
    :include    => :mission_group,
    :order      => "mission_groups.level"
   }

  before_create :set_completed
  after_create  :apply_payouts

  delegate :title, :to => :mission_group

  attr_reader :payouts

  def completed?
    self.new_record? ? (missions_completed? && bosses_completed?) : self[:completed]
  end

  protected

  def missions_completed?
    (mission_group.mission_ids - character.missions.completed_ids).empty?
  end

  def bosses_completed?
    true
  end

  def set_completed
    self.completed = true
  end

  def apply_payouts
    @payouts = mission_group.payouts.apply(character, :complete)
  end
end