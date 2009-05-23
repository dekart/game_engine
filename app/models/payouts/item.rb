module Payouts
  class Item < Base
    def initialize(item, options = {})
      @value    = item.is_a?(::Item) ? item.id : item
      @options  = options
    end

    def item
      ::Item.find_by_id(self.value)
    end

    def apply(character)
      if options[:remove] and inventory = character.inventories.find_by_item_id(self.item.id)
        inventory.destroy

        @action = :spent
      else
        character.inventories.create(
          :item           => self.item,
          :free_of_charge => true
        )

        @action = :received
      end
    end
  end
end