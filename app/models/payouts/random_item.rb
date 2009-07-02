module Payouts
  class RandomItem < Base
    attr_accessor :availability
    
    def item
      return @item if @item

      source = ::Item

      @item = source.first(
        :conditions => ["basic_price <= ?", self.value],
        :order => "RAND()"
      )
    end

    def apply(character)
      character.inventories.create(
        :item           => self.item,
        :free_of_charge => true
      )
    end
  end
end