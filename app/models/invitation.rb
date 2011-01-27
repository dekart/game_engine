class Invitation < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"

  named_scope :for_user, Proc.new{|user|
    {
      :conditions => ["receiver_id = ? AND accepted IS NULL", user.facebook_id],
      :include    => {:sender => :character},
      :order      => "created_at DESC"
    }
  }

  validates_uniqueness_of :receiver_id, :scope => :sender_id
  
  after_create :schedule_user_counter_update

  def receiver
    User.find_by_facebook_id(receiver_id)
  end

  def accept!
    transaction do
      FriendRelation.create(
        :owner      => sender.character,
        :character  => receiver.character
      )

      FriendRelation.create(
        :owner      => receiver.character,
        :character  => sender.character
      )

      update_attribute(:accepted, true)
      
      schedule_user_counter_update
    end
  end

  def ignore!
    transaction do
      update_attribute(:accepted, :false)
      
      schedule_user_counter_update
    end
  end
  
  def schedule_user_counter_update
    receiver.try(:schedule_counter_update)
  end
end
