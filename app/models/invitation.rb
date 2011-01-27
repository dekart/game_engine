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
    end
  end

  def ignore!
    update_attribute(:accepted, :false)
  end
end
