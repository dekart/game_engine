class Promotion < ActiveRecord::Base
  extend HasPayouts

  has_many :promotion_receipts, :dependent => :delete_all

  has_payouts
  
  validates_presence_of :text, :valid_till

  def to_param
    "#{self.id}-#{self.secret}"
  end

  def secret
    Digest::MD5.hexdigest("#{self.id}-#{self.created_at}")[0..5]
  end

  def expired?
    Time.now > self.valid_till
  end

  def can_be_received?(character, secret)
    (secret == self.secret) &&
    !expired? &&
    self.promotion_receipts.find_by_character_id(character.id).nil?
  end
end
