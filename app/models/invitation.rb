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
    User.find_by_facebook_id(self.receiver_id)
  end
  
  def accept!
    self.class.transaction do
      Relation.create(
        :source_character => self.sender.character,
        :target_character => self.receiver.character
      )

      Relation.create(
        :target_character => self.sender.character,
        :source_character => self.receiver.character
      )

      self.update_attribute(:accepted, true)
    end
  end

  def ignore!
    self.update_attribute(:accepted, :false)
  end
end
