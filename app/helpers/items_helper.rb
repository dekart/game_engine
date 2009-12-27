module ItemsHelper
  def item_image(item, format)
    if item.image?
      fb_tag(:img, 
        fb_ta(:src, image_path(item.image.url(format))) + 
        fb_ta(:alt, fb_i(item.name)) + 
        fb_ta(:title, fb_i(item.name))
      )
    else
      fb_i(item.name)
    end
  end
end
