module Payouts
  class Item < Base
    def value=(value)
      @value = value.is_a?(::Item) ? value.id : value.to_i
    end

    def item
      ::Item.find_by_id(self.value)
    end

    def apply(character)
      if self.action == :remove and inventory = character.inventories.find_by_item_id(self.item.id)
        inventory.destroy
      else
        character.inventories.create(
          :item           => self.item,
          :free_of_charge => true
        )
      end
    end
  end
end