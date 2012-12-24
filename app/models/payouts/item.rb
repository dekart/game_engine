# encoding: utf-8

module Payouts
  class Item < Base
    delegate :state, :to => :item

    def value=(value)
      @value = value.is_a?(::Item) ? value.id : value.to_i
    end

    def amount=(value)
      @amount = value.to_i
    end

    def amount
      @amount || 1
    end

    def item
      @item ||= ::Item.find_by_id(value)
    end

    def apply(character, reward, reference)
      if action == :remove
        reward.take_item(item, amount)
      else
        reward.give_item(item, amount)
      end
    end

    def preview(reward)
      reward.values[:items][item.alias] ||= [item, 0]

      if action == :remove
        reward.values[:items][item.alias][1] -= amount
      else
        reward.values[:items][item.alias][1] += amount
      end
    end

    def to_s
      "%s: %s × %d (%d%% %s)" % [
        apply_on_label,
        item.name,
        amount,
        chance,
        action
      ]
    end
  end
end
