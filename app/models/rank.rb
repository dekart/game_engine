class Rank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission

  named_scope :completed, {
    :conditions => {:completed => true},
    :include    => {:mission => :mission_group},
    :order      => "mission_groups.level, missions.money_max"
   }

  before_save :check_progress

  def just_completed?
    self.win_count == self.mission.win_amount
  end
  
  protected

  def check_progress
    self.completed = (self.win_count >= self.mission.win_amount)
    
    return true
  end
end
