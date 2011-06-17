module ItemsHelper
  def item_image(item, format, options = {})
    if tooltip = options.delete(:tooltip)
      tooltip = {} unless tooltip.is_a?(Hash)

      tooltip = {
        :content => {:text => item_tooltip_content(item)},
        :position => {
          :my => 'bottom center',
          :at => 'top center'
        }
      }.deep_merge(tooltip)

      options['data-tooltip'] = tooltip.to_json
    end
    
    options.reverse_merge!(
      :alt => item.name, 
      :title => item.name
    )
      
    image_tag(item.image.url(format), options)
  end
  
  def item_tooltip_content(item)
    %{
      <div class="tooltip_content">
        <h2>#{item.name}</h2>
        <div class="description">#{ item.description }</div>
        <div class="payouts">#{ render("items/effects", :item => item) }</div>
      </div>
    }.gsub!(/[\n\s]+/, ' ').html_safe
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
