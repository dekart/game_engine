class MissionGroupRank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission_group

  named_scope :completed, {
    :conditions => {:completed => true},
    :include    => :mission_group,
    :order      => "mission_groups.level"
   }

  before_save :set_completed

  delegate :title, :to => :mission_group

  protected

  def set_completed
    self.completed = true
  end
end