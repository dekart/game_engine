module News
  class PropertyAction < Base
    def result
      data[:result]
    end

    def action
      data[:action]
    end

    def property
      @property || find_property
    end

  protected
    def find_property
      @property = Property.find(data[:property_id])
    end
  end
end
