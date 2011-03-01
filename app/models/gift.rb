class Gift < ActiveRecord::Base
  belongs_to :app_request
  belongs_to :sender, :class_name => "Character"
  belongs_to :item
  
  named_scope :for_character, Proc.new {|character|
    {
      :conditions => {:receiver_id => character.user.facebook_id}
    }
  }
  named_scope :accepted_recently, Proc.new {
    {
      :conditions => ["state = 'accepted' AND accepted_at >= ?", Setting.i(:gifting_repeat_accept_delay).hours.ago]
    }
  }
  
  state_machine :initial => :pending do
    state :accepted do
      validate :repeat_accept_check
    end

    event :accept do
      transition :pending => :accepted
    end
    
    after_transition :on => :accept do |gift|
      gift.update_attribute(:accepted_at, Time.now)
      
      gift.send(:give_item_to_receiver)
      gift.send(:schedule_app_request_deletion)
    end
  end
  
  attr_accessor :inventory
  
  def receiver
    @receiver ||= User.find_by_facebook_id(receiver_id).character
  end
  
  protected

  def give_item_to_receiver
    @inventory = receiver.inventories.give!(item)
  end

  def schedule_app_request_deletion
    Delayed::Job.enqueue(Jobs::RequestDelete.new(app_request_id)) if app_request_id
  end
  
  def repeat_accept_check
    if sender.gifts.for_character(receiver).accepted_recently.count > 0
      errors.add(:base, :accepted_recently, :hours => Setting.i(:gifting_repeat_accept_delay))
    end
  end
end
