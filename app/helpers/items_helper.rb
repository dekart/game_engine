module ItemsHelper
  def item_image(item, format, options = {})
    
    tooltip_js = ""
    if with_tooltip = options.delete(:tooltip)
      options['data-item-tooltip'] = dom_id(item, :tooltip)
      tooltip_js = item_tooltip_js(item)
    end
    
    if item.image?
      options.reverse_merge!(
        :alt => item.name, 
        :title => item.name
      )
      
      image = image_tag(item.image.url(format), options)
    else
      image = content_tag(:p, item.name, options)
    end
    
    image << tooltip_js
  end

  def item_tooltip(item)
    content_tag(:div,
      content_tag(:h2, item.name) << content_tag(:div, item.description, :class => 'description') << 
        render("items/effects", :item => item),
      :class  => "payouts tooltip_content",
      :id     => dom_id(item, :tooltip)
    )
  end
  
  def item_tooltip_js(item)
    id = dom_id(item, :tooltip)
    javascript_tag("$('[data-item-tooltip=\"#{id}\"]').itemTooltip('#{escape_javascript(item_tooltip(item))}');")
  end
  
  def item_price_inline(item, amount = 1)
    if item.price?
      result = [].tap do |prices|
        if item.basic_price > 0
          prices << content_tag(:span,
            attribute_requirement_text(:basic_money, number_to_currency(item.basic_price * amount)),
            :class => :basic_money
          )
        end

        if item.vip_price > 0
          prices << content_tag(:span,
            attribute_requirement_text(:vip_money, item.vip_price * amount),
            :class => :vip_money
          )
        end
      end

      result.to_sentence.html_safe
    else
      t("items.item.free")
    end
  end
end
