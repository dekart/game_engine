module Payouts
  class Property < Base
    delegate :state, :to => :property_type

    def value=(value)
      @value = value.is_a?(::PropertyType) ? value.id : value.to_i
    end

    def property_type
      @property_type ||= ::PropertyType.find_by_id(value)
    end

    def apply(character, reward, reference)
      if action != :remove
        reward.give_property(property_type)
      end
    end

    def preview(reward)
      if action != :remove
        reward.values[:properties][property_type.id] ||= [property_type, 1]
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
