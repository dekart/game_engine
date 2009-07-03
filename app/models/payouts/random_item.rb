module Payouts
  class RandomItem < Base
    attr_accessor :availability, :allow_vip
    
    def item
      return @item if @item

      source = ::Item

      source = source.available_in(self.availability) unless self.availability.blank?
      source = source.basic unless self.allow_vip

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