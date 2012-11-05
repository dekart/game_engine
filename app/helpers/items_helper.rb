module ItemsHelper
  def item_effects(item)
    raise "Wrong object class: #{item.class}" unless item.is_a?(Item)

    $memory_store.fetch("#{ item.cache_key }/effects") do
      render('items/effects', :item => item)
    end
  end

  def item_image(item, format, options = {})
    if tooltip = options.delete(:tooltip)
      options['data-tooltip-content'] = escape_once(item_tooltip_content(item)).html_safe
    end

    if show_details = options.delete(:details)
      options['data-item-details-url'] = item_path(item)

      if options['class']
        options['class'] += ' clickable'
      else
        options['class'] = 'clickable'
      end
    end

    options.reverse_merge!(
      :alt => item.name,
      :title => item.name
    )

    image_tag(item.pictures? ? item.pictures.url(format) : image_path("1px.gif"), options)
  end

  def item_tooltip_content(item)
    item = item.item if item.is_a?(Character::Equipment::Inventories::Inventory)

    %{
      <div class="tooltip_content">
        <h2>#{item.name}</h2>
        <div class="payouts">#{ item_effects(item) }</div>
      </div>
    }.gsub!(/[\n\s]+/, ' ')
  end

  def item_price_inline(item, amount = 1)
    if item.price?
      result = [].tap do |prices|
        if item.basic_price > 0
          prices << span_tag(
            attribute_requirement_text(:basic_money,
              number_to_currency(item.basic_price * amount)
            ),
            :basic_money
          )
        end

        if item.vip_price > 0
          prices << span_tag(
            attribute_requirement_text(:vip_money, item.vip_price * amount),
            :vip_money
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
      span_tag(
        t('items.item.package_size',
          :amount     => item.package_size,
          :help_link  => help_link(:items_package)
        ),
        :package_size
      ).html_safe
    end
  end
end
