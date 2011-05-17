class AppRequest::Gift < AppRequest::Base
  state_machine :initial => :pending do
    state :accepted do
      validate :repeat_accept_check
    end
  end
  
  attr_accessor :inventory
  
  class << self
    def accepted_recently?(sender, receiver)
      with_state(:accepted).
      between(sender, receiver).
      scoped(:conditions => ["accepted_at >= ?", Setting.i(:gifting_repeat_accept_delay).hours.ago]).
      count > 0
    end
  end
  
  def acceptable?
    !(accepted? || self.class.accepted_recently?(sender, receiver))
  end
  
  def item
    target
  end
  
  protected
  
  def after_accept
    super
    
    @inventory = receiver.inventories.give!(item)
  end
  
  def repeat_accept_check
    if state_changed? and self.class.accepted_recently?(sender, receiver)
      errors.add(:base, :accepted_recently, :hours => Setting.i(:gifting_repeat_accept_delay))
    end
  end
end
