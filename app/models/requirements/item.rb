module Requirements
  class Item < Base
    def initialize(item)
      @value = item.is_a?(::Item) ? item.id : item
    end

    def satisfies?(character)
      character.items.include?(self.item)
    end

    def item
      ::Item.find_by_id(self.value)
    end
  end
end