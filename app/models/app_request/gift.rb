class AppRequest::Gift < AppRequest::Base
  state_machine :initial => :pending do
    state :accepted do
      validate :repeat_accept_check
    end
  end
  
  attr_accessor :inventory
  
  class << self
    def receiver_cache_key(receiver)
      "character_#{ receiver.id }_accepted_gift_senders"
    end
    
    def accepted_recently?(sender, receiver)
      ids = Rails.cache.fetch(receiver_cache_key(receiver), :expire_in => 15.minutes) do
        with_state(:accepted).
        for(receiver).
        scoped(:conditions => ["accepted_at >= ?", Setting.i(:gifting_repeat_accept_delay).hours.ago]).
        all(:select => "sender_id").map{|r| r.sender_id }
      end
      
      ids.include?(sender.id)
    end
  end
  
  #FIXME Checking gift item hack should be done on processing rather than when checking acceptability
  def acceptable?
    !(accepted? || self.class.accepted_recently?(sender, receiver)) && 
      item_gift? && !gift_for_yourself?
  end
  
  #prevent hacking
  def item_gift?
    item && item.availability == :gift
  end
  
  #prevent hacking
  def gift_for_yourself?
    sender == receiver 
  end
  
  def correct?
    item_gift? && !gift_for_yourself?
  end
  
  def acceptance_error
    I18n.t('activerecord.errors.models.app_request/gift.accepted_recently', :hours => Setting.i(:gifting_repeat_accept_delay))
  end
  
  # FIXME remove temporary support of old data keys
  def item
    target || (Item.find(data['item_id']) if data && data['item_id'])
  end
  
  protected
  
  def after_accept
    super
    
    @inventory = receiver.inventories.give!(item)
    
    Rails.cache.delete(self.class.receiver_cache_key(receiver))
  end
  
  def repeat_accept_check
    if state_changed? and self.class.accepted_recently?(sender, receiver)
      errors.add(:base, :accepted_recently, :hours => Setting.i(:gifting_repeat_accept_delay))
    end
  end
end
