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
      fb_tag(:img,
        fb_ta(:src, image_path(property.image.url(format))) +
        fb_ta(:alt, fb_i(property.name)) +
        fb_ta(:title, fb_i(property.name))
      )
    end
  end

  def property_stream_dialog(property)
    show_stream_dialog(
      :attachment => {
        :caption => t("stories.property.title", :property => property.name, :app => t("app_name")),
        :media => property.image? ? [
          {
            :type => "image",
            :src  => image_path(property.image.url),
            :href => new_property_url
          }
        ] : nil
      }
    )
  end
end
