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
      missing_amount(character) == 0
    end

    def missing_amount(character)
      if inventory = character.inventories.find_by_item_id(item.id)
        result = amount - inventory.amount

        result > 0 ? result : 0
      else
        amount
      end
    end
  end
end