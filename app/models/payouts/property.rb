module Payouts
  class Property < Base
    def value=(value)
      @value = value.is_a?(::PropertyType) ? value.id : value.to_i
    end

    def property_type
      ::PropertyType.find_by_id(self.value)
    end

    def apply(character)
      if self.action == :remove and property = character.properties.find_by_property_type_id(self.property_type.id)
        property.destroy
      else
        character.properties.create(
          :property_type  => self.property_type,
          :free_of_charge => true
        )
      end
    end
  end
end