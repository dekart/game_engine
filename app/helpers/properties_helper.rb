module PropertiesHelper
  def property_type_list(types, properties, &block)
    result = ""

    types.each do |type|
      property = properties.detect{|p| p.property_type == type }

      next if type.availability != :shop and property.nil?

      result << capture(type, property, &block)
    end

    result.html_safe!

    concat(result)
  end

  def property_image(property, format)
    if property.image?
      image_tag(property.image.url(format), :alt => property.name, :title => property.name)
    else
      property.name
    end
  end
end
