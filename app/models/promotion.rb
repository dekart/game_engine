class Promotion < ActiveRecord::Base
  extend SerializeWithPreload

  has_many :promotion_receipts

  serialize :payouts, Payouts::Collection
  
  validates_presence_of :text, :valid_till

  def payouts
    super || Payouts::Collection.new
  end

  def payouts=(collection)
    unless collection.is_a?(Payouts::Collection)
      items = collection.values.collect do |payout|
        Payouts::Base.by_name(payout[:type]).new(payout.except(:type))
      end

      collection = Payouts::Collection.new(*items)
    end

    super(collection)
  end

  def to_param
    "#{self.id}-#{self.secret}"
  end

  def secret
    Digest::MD5.hexdigest("#{self.id}-#{self.created_at}")[0..5]
  end

  def can_be_received?(character, secret)
    (secret == self.secret) &&
    (Time.now <= self.valid_till) &&
    self.promotion_receipts.find_by_character_id(character.id).nil?
  end
end
