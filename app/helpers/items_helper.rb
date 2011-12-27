module ItemsHelper
  def item_effects(item)
    raise "Wrong object class: #{item.class}" unless item.is_a?(Item)

    $memory_store.fetch(item.cache_key, :expires_in => 1.minute) do
      render('items/effects', :item => item)
    end
  end

  def item_image(item, format, options = {})
    if tooltip = options.delete(:tooltip)
      tooltip = {} unless tooltip.is_a?(Hash)

      tooltip = {
        :content => {:text => item_tooltip_content(item)},
        :position => {
          :my => 'bottom center',
          :at => 'top center',
          :viewport => true,
          :adjust => {
           :x => 0,
           :y => 0,
           :method => 'shift'
          }
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
    item = item.item if item.is_a?(Inventory)

    %{
      <div class="tooltip_content">
        <h2>#{item.name}</h2>
        <div class="description">#{ item.description }</div>
        <div class="payouts">#{ item_effects(item) }</div>
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

  def item_package(item, &block)
    if item.package_size > 1
      content_tag(:span, 
        t('items.item.package_size', 
          :amount     => item.package_size, 
          :help_link  => help_link(:items_package)
        ).html_safe, 
        :class => :package_size
      )
    end
  end
end
