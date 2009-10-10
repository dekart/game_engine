class HelpRequest < ActiveRecord::Base
  belongs_to  :character
  belongs_to  :context, :polymorphic => true
  has_many    :help_results, :dependent => :delete_all

  validates_presence_of :character, :context

  def self.latest(context_class)
    self.first(
      :conditions => [
        "context_type = ?", context_class.is_a?(Class) ? context_class.to_s : context_class.to_s.classify
      ],
      :order      => "created_at DESC"
    )
  end
  
  def expired?
    Time.now > self.expire_at
  end

  def expire_at
    self.created_at + Configuration[:help_request_expire_period].hours
  end

  def stop_display_at
    self.expire_at + Configuration[:help_request_display_period].hours
  end

  def should_be_displayed?
    Time.now < self.stop_display_at && self.help_results.size > 0
  end
end
