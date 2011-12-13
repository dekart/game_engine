module Requirements
  class Property < Base
    delegate :state, :to => :property_type
    
    def value=(value)
      @value = value.is_a?(::PropertyType) ? value.id : value.to_i
    end

    def level
      @level || 1
    end

    def level=(value)
      @level = value.to_i
    end
    
    def display_level?
      level > 1 and property_type.upgradeable?
    end

    def property_type
      @property_type ||= ::PropertyType.find_by_id(value)
    end

    def satisfies?(character)
      if property = character.properties.find_by_property_type_id(@value)
        property.active? and property.level >= level
      else
        false
      end
    end

    def to_s
      if property_type.upgradeable?
        I18n.t('requirements.property.text', 
          :name   => property_type.name, 
          :level  => level
        )
      else
        property_type.name
      end
    end
  end
end
