class Rank < ActiveRecord::Base
  belongs_to :character
  belongs_to :mission

  named_scope :completed, {
    :conditions => {:completed => true},
    :include    => :mission,
    :order      => "missions.level, missions.ep_cost"
   }

  before_save :check_completeness
  
  def completeness
    self.completed ? "Complete!" : "%d%%" % (self.win_count.to_f / self.mission.win_amount * 100)
  end

  protected

  def check_completeness
    self.completed = (self.win_count == self.mission.win_amount)
    
    return true
  end
end
