class AppRequest::Gift < AppRequest::Base
  state_machine :initial => :pending do
    state :accepted do
      validate :repeat_accept_check
    end
  end
  
  attr_accessor :inventory
  
  class << self
    def ids_to_exclude_for(character)
      Rails.cache.fetch(exclude_ids_cache_key(character), :expires_in => 15.minutes) do
        from_character(character).sent_after(Setting.i(:gifting_repeat_accept_delay).hours.ago).receiver_ids
      end
    end
    
    def receiver_cache_key(receiver)
      "character_#{ receiver.id }_accepted_gift_senders"
    end
    
    def accepted_recently?(sender, receiver)
      ids = Rails.cache.fetch(receiver_cache_key(receiver), :expires_in => 15.minutes) do
        with_state(:accepted).
        for_character(receiver).
        accepted_after(Setting.i(:gifting_repeat_accept_delay).hours.ago).
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
  
  def can_send_back?
    !AppRequest::Gift.ids_to_exclude_for(receiver).include?(sender.facebook_id)
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
