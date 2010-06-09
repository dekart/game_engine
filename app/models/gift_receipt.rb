class GiftReceipt < ActiveRecord::Base
  belongs_to :gift, :counter_cache => :receipts_count
  belongs_to :character

  named_scope :unaccepted, :conditions => { :accepted => false }

  named_scope :for_character, lambda { |character|
    { :conditions => [ "character_id = ? OR facebook_id = ?", character.id, character.user.facebook_id ] }
  }
  named_scope :recent, Proc.new{|time_range|
    { :conditions => ["gift_receipts.created_at > ?", time_range] }
  }


  def give_item_to_character!
    transaction do
      self.character = User.find_by_facebook_id(facebook_id).character
      self.accepted = true

      save!

      character.inventories.give!(gift.item)
    end
  end
end
