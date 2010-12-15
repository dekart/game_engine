class GiftReceipt < ActiveRecord::Base
  belongs_to :gift, :counter_cache => :receipts_count
  belongs_to :character

  named_scope :unaccepted, :conditions => { :accepted => false }

  named_scope :for_character, lambda { |character|
    { :conditions => [ "character_id = ? OR facebook_id = ?", character.id, character.user.facebook_id ] }
  }
  named_scope :recent, Proc.new{
    { 
      
    }
  }

  class << self
    def recent_facebook_ids
      if Setting.i(:gifting_repeat_send_delay) > 0
        all(
          :select => "DISTINCT(facebook_id)",
          :conditions => ["gift_receipts.created_at > ?", Setting.i(:gifting_repeat_send_delay).hours.ago]
        ).collect{|r| r.facebook_id }
      else
        []
      end
    end
  end

  def give_item!
    transaction do
      self.character = User.find_by_facebook_id(facebook_id).character
      self.accepted = true

      save!

      character.inventories.give!(gift.item)
    end
  end
end
