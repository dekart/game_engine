class CollectionRank < ActiveRecord::Base
  belongs_to :character
  belongs_to :collection

  attr_reader :payouts, :applied

  validate :check_items

  def apply!
    return unless valid?

    transaction do
      @payouts = collection.payouts.apply(character, :collected) + collection.spendings.apply(character, :collected)

      increment(:collection_count)

      character.save
      save

      @applied = true
    end
  end

  protected

  def check_items
    errors.add(:character, :not_enough_items) unless character.items.count(:conditions => {:id => collection.item_ids}) == collection.item_ids.size
  end
end
