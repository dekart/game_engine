module Requirements
  class Item < Base
    delegate :state, :to => :item
    
    def value=(value)
      @value = value.is_a?(::Item) ? value.id : value.to_i
    end

    def amount
      @amount || 1
    end

    def amount=(value)
      @amount = value.to_i
    end

    def item
      @item ||= ::Item.find_by_id(value)
    end

    def satisfies?(character)
      missing_amount(character) == 0
    end

    def missing_amount(character)
      if inventory = character.inventories.find_by_item(item)
        result = amount - inventory.amount

        result > 0 ? result : 0
      else
        amount
      end
    end
    
    def to_s
      I18n.t('requirements.item.text', 
        :name   => item.try(:name) || I18n.t("requirements.item.missing"), 
        :amount => amount
      )
    end
  end
end
