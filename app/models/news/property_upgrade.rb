module News
  class PropertyUpgrade < Base
    def property
      @property ||= Property.find(data[:property_id])
    end
    
    def level
      data[:level] || property.level
    end
  end
end
