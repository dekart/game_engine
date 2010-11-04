module News
  class PropertyCollect < Base
    def property
      @property ||= Property.find(data[:property_id])
    end
  end
end
