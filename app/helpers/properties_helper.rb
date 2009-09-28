module PropertiesHelper
  def property_type_list(types, properties, &block)
    result = ""

    types.each do |type|
      property = properties.detect{|p| p.property_type == type }

      next if type.availability != "shop" and property.nil?

      result << capture(type, property, &block)
    end

    concat(result)
  end
end
