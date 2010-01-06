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

  protected

  def set_completed
    self.completed = true
  end

  def apply_payouts
    @payouts = mission_group.payouts.apply(character, :complete)
  end
end