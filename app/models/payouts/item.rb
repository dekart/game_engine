module Payouts
  class Item < Base
    def value=(value)
      @value = value.is_a?(::Item) ? value.id : value.to_i
    end

    def item
      ::Item.find_by_id(self.value)
    end

    def apply(character)
      if self.action == :remove
        character.inventories.take!(self.item)
      else

        character.inventories.give!(self.item)
      end
    end
  end
end