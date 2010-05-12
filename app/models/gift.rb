class Gift < ActiveRecord::Base
  belongs_to :character
  belongs_to :item

  has_many :receipts, :class_name => "GiftReceipt"

  def recipient_ids
    @recipient_ids ||= self.recipients.to_s.split(",").collect{|id| id.to_i }
  end

  def can_receive?(character)
    recipient_ids.include?(character.user.facebook_id) and receipts.find_by_character_id(character.id).nil?
  end

  named_scope :for_character, lambda { |character|
    fb_id = character.user.facebook_id
    { 
      :joins => "LEFT JOIN gift_receipts ON gifts.id = gift_receipts.gift_id AND gift_receipts.character_id = #{character.id}",
      :conditions => ["gifts.recipients LIKE '%?%' AND gift_receipts.id IS NULL", fb_id]
    }
  }
end
