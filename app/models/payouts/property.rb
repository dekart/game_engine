module Payouts
  class Property < Base
    def value=(value)
      @value = value.is_a?(::PropertyType) ? value.id : value.to_i
    end

    def property_type
      ::PropertyType.find_by_id(self.value)
    end

    def apply(character)
      if action != :remove
        character.properties.give!(property_type)
      end
    end
  end
end