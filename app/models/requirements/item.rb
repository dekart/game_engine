module Requirements
  class Item < Base
    def initialize(options = {})
      super(options)

      @amount = options[:amount].to_i
    end

    def item
      ::Item.find_by_id(value)
    end

    def amount
      @amount && @amount.to_i > 0 ? @amount : 1
    end

    def satisfies?(character)
      inventory = character.inventories.detect{|i| i.item == item }

      inventory && inventory.amount >= amount
    end
  end
end