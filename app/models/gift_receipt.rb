class GiftReceipt < ActiveRecord::Base
  belongs_to :gift, :counter_cache => :receipts_count
  belongs_to :character

  after_create :give_item_to_character

  protected

  def give_item_to_character
    self.character.inventories.give!(self.gift.item)
  end
end
