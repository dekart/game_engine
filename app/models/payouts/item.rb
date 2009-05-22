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
      if options[:chance].nil? or (rand(100) <= options[:chance])
        character.inventories.create(
          :item           => self.item,
          :free_of_charge => true
        )
      end
    end
  end
end