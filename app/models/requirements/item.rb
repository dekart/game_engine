module Requirements
  class Item < Base
    def initialize(item)
      @value    = item.is_a?(::Item) ? item.id : item.to_i
    end

    def item
      ::Item.find_by_id(self.value)
    end

    def satisfies?(character)
      character.items.include?(self.item)
    end
  end
end