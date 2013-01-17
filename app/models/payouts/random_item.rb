module Payouts
  class RandomItem < Base
    attr_accessor :item, :availability, :allow_vip, :item_set_id, :shift_item_set

    def item_set
      @item_set ||= (@item_set_id ? ItemSet.find_by_id(@item_set_id) : nil)
    end

    def item_set_id=(value)
      @item_set_id = value.to_i
    end

    def apply(character, reward, reference)
      if @item = choose_item(character)
        reward.give_item(@item, 1)
      end
    end

    def preview(reward)
      if action != :remove
        reward.values[:random_item] += 1
      end
    end

    def item_ids
      Array.wrap(@item_ids).collect{|id| id.to_i }
    end

    def allow_vip=(value)
      @allow_vip = (value.to_i == 1)
    end

    def shift_item_set=(value)
      @shift_item_set = (value.to_i == 1)
    end

    def to_s
      if item_set
        "%s: Random Item from '%s' (%d%% %s)" % [
          apply_on_label,
          item_set.name,
          chance,
          action
        ]
      else
        "%s: Random Item %s %s %s (%d%% %s)" % [
          apply_on_label,
          availability || "any",
          value,
          allow_vip ? "vip" : "basic",
          chance,
          action
        ]
      end
    end

    protected

    def choose_item(character)
      if item_set
        item_set.random_item(shift_item_set ? character.id % item_set.size : 0)
      else
        scope = ::Item.with_state(:visible)
        scope = scope.available_in(availability) unless availability.blank?
        scope = scope.basic unless allow_vip

        scope.first(
          :conditions => ["basic_price <= ?", value],
          :order => "RAND()"
        )
      end
    end
  end
end
