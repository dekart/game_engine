class HelpRequest < ActiveRecord::Base
  VALID_DURING = 1.minute#24.hours
  
  belongs_to  :character
  belongs_to  :mission
  has_many    :help_results

  validates_presence_of :character, :mission

  def self.latest
    self.first(:order => "created_at DESC")
  end
  
  def expired?
    self.created_at < Time.now - VALID_DURING
  end
end
