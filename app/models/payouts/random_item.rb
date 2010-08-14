module Payouts
  class RandomItem < Base
    attr_accessor :availability, :allow_vip, :item_ids
    
    def item
      return @item if @item

      source = ::Item

      if item_ids.is_a?(Array) && item_ids.any?
        @item = source.find(item_ids).rand
      else
        source = source.with_state(:visible)
        source = source.available_in(availability) if availability.present?
        source = source.basic unless allow_vip

        @item = source.first(
          :conditions => ["basic_price <= ?", value],
          :order => "RAND()"
        )
      end
    end

    def apply(character)
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