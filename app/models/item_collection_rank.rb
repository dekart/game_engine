class ItemCollectionRank < ActiveRecord::Base
  belongs_to :character
  belongs_to :collection, :class_name => "ItemCollection"

  attr_reader :payouts

  validate :check_items

  def apply!
    return unless valid?

    transaction do
      increment!(:collection_count)

      @payouts = collection.payouts.apply(character, (collection_count > 1 ? :repeat_collected : :collected), collection)
      @payouts += collection.spendings.apply(character, :collected, collection)

      character.save!

      @applied = true
    end
  end

  def collected?
    collection_count > 0
  end

  def applied?
    @applied
  end

  protected

  def check_items
    unless collection.missing_items(character).empty?
      errors.add(:character, :not_enough_items)
    end
  end
end
