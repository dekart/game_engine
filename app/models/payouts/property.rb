module Payouts
  class Property < Base
    delegate :state, :to => :property_type
    
    def value=(value)
      @value = value.is_a?(::PropertyType) ? value.id : value.to_i
    end

    def property_type
      @property_type ||= ::PropertyType.find_by_id(value)
    end

    def apply(character, reference = nil)
      if action != :remove
        character.properties.give!(property_type)
      end
    end
    
    def to_s
      "%s: %s (%d%% %s)" % [
        apply_on_label,
        property_type.name,
        chance,
        action
      ]
    end
  end
end
