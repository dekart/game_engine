module Payouts
  class Property < Base
    def value=(value)
      @value = value.is_a?(::PropertyType) ? value.id : value.to_i
    end

    def property_type
      ::PropertyType.find_by_id(self.value)
    end

    def apply(character)
      if self.action == :remove
        character.properties.take!(self.property_type)
      else
        character.properties.give!(self.property_type)
      end
    end
  end
end