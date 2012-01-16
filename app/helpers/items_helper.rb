module ItemsHelper
  def item_effects(item)
    raise "Wrong object class: #{item.class}" unless item.is_a?(Item)

    $memory_store.fetch("#{ item.cache_key }/effects") do
      render('items/effects', :item => item)
    end
  end

  def item_image(item, format, options = {})
    return unless item.pictures?

    if tooltip = options.delete(:tooltip)
      options['data-tooltip'] = item_image_tooltip_options(item, tooltip).to_json
    end
    
    if tooltip_on_click = options.delete(:tooltip_on_click)
      options['data-tooltip-on-click'] = item_image_tooltip_on_click_options(item, tooltip_on_click).to_json
      
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
      
    image_tag(item.pictures.url(format), options)
  end
  
  def item_tooltip_content(item)
    item = item.item if item.is_a?(Inventory)

    %{
      <div class="tooltip_content">
        <h2>#{item.name}</h2>
        <div class="payouts">#{ item_effects(item) }</div>
      </div>
    }.gsub!(/[\n\s]+/, ' ').html_safe
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

  protected

    def item_image_tooltip_options(item, tooltip)
      tooltip = {} unless tooltip.is_a?(Hash)

      {
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
    end

    def item_image_tooltip_on_click_options(item, tooltip)
      tooltip = {} unless tooltip.is_a?(Hash)

      tooltip = {
        :content => {
          :title => {
            :text => item.name,
            :button => 'Close'
          },
          :text => %{<div class="spinner">#{ asset_image_tag(:spinner) }</div>}, # show spinner while tooltip loading
          :ajax => {
            :url => item_path(item)
          }
        },
        :position => {
          :my => 'bottom center',
          :at => 'top center',
          :viewport => true,
          :adjust => {
            :x => 0,
            :y => 0,
            :method => 'shift'
          },
        },
        :show => {
          :event => 'click',
          :solo => true
        },
        :hide => 'unfocus'
      }.deep_merge(tooltip)
    end
end
