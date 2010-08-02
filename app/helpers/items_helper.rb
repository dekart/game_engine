module ItemsHelper
  def item_image(item, format, options = {})
    if item.image?
      image_tag(item.image.url(format), options.reverse_merge(:alt => item.name, :title => item.name))
    else
      item.name
    end
  end

  def item_tooltip(item)
    content_tag(:div,
      content_tag(:h3, item.name) + render("items/effects", :item => item),
      :class  => "payouts tooltip_content",
      :id     => dom_id(item, :tooltip)
    )
  end
end
