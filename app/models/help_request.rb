class HelpRequest < ActiveRecord::Base
  EXPIRE_PERIOD = 24.hours
  DISPLAY_PERIOD = 24.hours
  
  belongs_to  :character
  belongs_to  :mission
  has_many    :help_results

  validates_presence_of :character, :mission

  def self.latest
    self.first(:order => "created_at DESC")
  end
  
  def expired?
    Time.now > self.expire_at
  end

  def expire_at
    self.created_at + EXPIRE_PERIOD
  end

  def stop_display_at
    self.expire_at + DISPLAY_PERIOD
  end

  def should_be_displayed?
    Time.now < self.stop_display_at && self.help_results.size > 0
  end
end
