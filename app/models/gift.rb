class Gift < ActiveRecord::Base
  belongs_to :sender, :class_name => "Character"
  belongs_to :item
  
  named_scope :for_character, Proc.new{|character|
    {
      :conditions => {:receiver_id => character.user.facebook_id}
    }
  }
  
  state_machine :initial => :pending do
    state :accepted

    event :accept do
      transition :pending => :accepted
    end
    
    after_transition :on => :accept do |gift|
      gift.give_item_to_receiver
    end
  end
  
  attr_accessor :inventory
  
  def receiver
    @receiver ||= User.find_by_facebook_id(receiver_id).character
  end
  
  def give_item_to_receiver
    @inventory = receiver.inventories.give!(item)
  end
end
