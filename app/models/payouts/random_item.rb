module Payouts
  class RandomItem < Base
    attr_accessor :availability, :allow_vip, :item_set_id

    def item_set
      @item_set ||= (@item_set_id ? ItemSet.find_by_id(@item_set_id) : nil)
    end

    def item_set_id=(value)
      @item_set_id = value.to_i
    end

    def item
      unless @item
        if item_set
          @item = item_set.random_item
        else
          scope = ::Item.with_state(:visible)
          scope = scope.available_in(availability) unless availability.blank?
          scope = scope.basic unless allow_vip

          @item = scope.first(
            :conditions => ["basic_price <= ?", value],
            :order => "RAND()"
          )
        end
      end

      @item
    end

    def apply(character, reference = nil)
      character.inventories.give!(item) if item
    end

    def item_ids
      Array.wrap(@item_ids).collect{|id| id.to_i }
    end

    def allow_vip=(value)
      @allow_vip = (value.to_i == 1)
    end
  end
end
