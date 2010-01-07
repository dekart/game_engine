module Payouts
  class Property < Base
    def value=(value)
      @value = value.is_a?(::PropertyType) ? value.id : value.to_i
    end

    def amount=(value)
      @amount = value.to_i
    end

    def amount
      @amount || 1
    end

    def property_type
      ::PropertyType.find_by_id(self.value)
    end

    def apply(character)
      if action == :remove
        character.properties.take!(property_type, amount)
      else
        character.properties.give!(property_type, amount)
      end
    end
  end
end