class Gift < ActiveRecord::Base
  belongs_to :character
  belongs_to :item

  has_many :receipts, :class_name => "GiftReceipt"

  def recipient_ids
    @recipient_ids ||= self.recipients.split(",").collect{|id| id.to_i }
  end

  def can_receive?(character)
    recipient_ids.include?(character.user.facebook_id) and receipts.find_by_character_id(character.id).nil?
  end
end
