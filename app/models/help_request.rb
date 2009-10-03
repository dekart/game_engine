class HelpRequest < ActiveRecord::Base
  EXPIRE_PERIOD = 24.hours
  DISPLAY_PERIOD = 24.hours
  
  belongs_to  :character
  belongs_to  :context, :polymorphic => true
  has_many    :help_results, :dependent => :delete_all

  validates_presence_of :character, :context

  def self.latest(context_class)
    self.first(
      :conditions => [
        "context_type = ?", context_class.is_a?(String) ? context_class.classify : context_class.to_s
      ],
      :order      => "created_at DESC"
    )
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
