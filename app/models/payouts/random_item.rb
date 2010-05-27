module Payouts
  class RandomItem < Base
    attr_accessor :availability, :allow_vip, :item_ids
    
    def item
      return @item if @item


      source = ::Item

      if item_ids.any?
        @item = source.find(item_ids).rand
      else
        source = source.available_in(self.availability) if availability.present?
        source = source.basic unless allow_vip

        @item = source.first(
          :conditions => ["basic_price <= ?", self.value],
          :order => "RAND()"
        )
      end
    end

    def apply(character)
      character.inventories.give!(item) if item
    end
  end
end