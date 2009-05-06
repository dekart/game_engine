class Rank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission

  named_scope :completed, {
    :conditions => {:completed => true},
    :include    => :mission,
    :order      => "missions.level, missions.ep_cost"
   }

  before_save :check_progress
  
  protected

  def check_progress
    self.completed = (self.win_count == self.mission.win_amount)
    
    return true
  end
end
