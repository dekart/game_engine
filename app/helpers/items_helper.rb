module ItemsHelper
  def item_image(item, format)
    if item.image?
      image_tag(item.image.url(format), :alt => item.name, :title => item.name)
    else
      item.name
    end
  end

  def item_tooltip(item)
    content_tag(:div,
      content_tag(:h3, item.name) + render("items/effects", :item => item),
      :class => "payouts tooltip_content"
    )
  end
end
