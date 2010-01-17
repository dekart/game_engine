module ItemsHelper
  def item_image(item, format)
    if item.image?
      image_tag(item.image.url(format), :alt => item.name, :title => item.name)
    else
      item.name
    end
  end
end
