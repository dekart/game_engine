class AppRequest::Gift < AppRequest::Base
  state_machine :initial => :pending do
    state :accepted do
      validate :repeat_accept_check
    end
  end

  attr_accessor :item

  class << self
    def stackable?
      true
    end

    def ids_to_exclude_for(character)
      Rails.cache.fetch(exclude_ids_cache_key(character), :expires_in => 15.minutes) do
        from_character(character).sent_after(repeat_accept_timeframe).receiver_ids
      end
    end

    def receiver_cache_key(receiver)
      "character_#{ receiver.id }_accepted_gift_senders"
    end

    def repeat_accept_timeframe
      Setting.i(:gifting_repeat_accept_delay).hours.ago
    end

    def recent_accepts(receiver)
      $redis.zrangebyscore(receiver_cache_key(receiver), repeat_accept_timeframe.to_i, "+inf").map{|i| i.to_i }
    end

    def accepted_recently?(sender, receiver)
      recent_accepts(receiver).include?(sender.id)
    end

    def store_accept_time(sender, receiver)
      # Remove already expired records
      $redis.zremrangebyscore(receiver_cache_key(receiver), 0, repeat_accept_timeframe.to_i)

      $redis.zadd(receiver_cache_key(receiver), Time.now.to_i, sender.id)
    end
  end

  def acceptance_error
    I18n.t('activerecord.errors.models.app_request/gift.accepted_recently', :hours => Setting.i(:gifting_repeat_accept_delay))
  end

  def item
    target
  end

  def can_send_back?
    !AppRequest::Gift.ids_to_exclude_for(receiver).include?(sender.facebook_id) && item.visible?
  end

  protected

  def after_process
    super

    mark_incorrect if !item_gift? or gift_for_yourself?
  end

  def after_accept
    super

    receiver.inventories.give!(item)

    self.class.store_accept_time(sender, receiver)

    true
  end

  def repeat_accept_check
    if state_changed? and self.class.accepted_recently?(sender, receiver)
      errors.add(:base, :accepted_recently, :hours => Setting.i(:gifting_repeat_accept_delay))
    end
  end

  #prevent hacking
  def item_gift?
    item && item.availability == :gift
  end

  #prevent hacking
  def gift_for_yourself?
    sender == receiver
  end
end
