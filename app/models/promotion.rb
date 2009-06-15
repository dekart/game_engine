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
        Payouts::Base.by_name(payout[:type]).new(payout[:value], payout[:options])
      end

      collection = Payouts::Collection.new(*items)
    end

    super(collection)
  end
end
