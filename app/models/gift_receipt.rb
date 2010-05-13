class GiftReceipt < ActiveRecord::Base
  belongs_to :gift, :counter_cache => :receipts_count
  belongs_to :character

  named_scope :unused, :conditions => { :accepted => false }

  named_scope :for_character, lambda { |character|
    { :conditions => [ "character_id = ? OR facebook_id = ?", character.id, character.user.facebook_id ] }
  }

  def give_item_to_character!
    self.character = User.find_by_facebook_id(facebook_id).character
    self.accepted = true
    save!
    self.character.inventories.give!(self.gift.item)
  end
end
