module InventoriesHelper
  def inventory_placement(character, placement, image_size, options = {})
    placement = placement.to_sym
    
    if inventory = character.holded_inventories.detect{|i| i.placement.to_sym == placement }
      code = image_tag(inventory.item.image.url(image_size))
      
      if options[:controls]
        code << link_to_remote(image_tag("icons/delete.gif"),
          :url => take_off_inventory_url(inventory, :canvas => false),
          :update => :result,
          :html => {:class => :take_off}
        )
      end

      return content_tag(:span, code, :class => placement)
    end
  end

  def inventory_placements_for(holder, options = {})
    options.reverse_merge!(:controls => true)
    
    content_tag(:div,
      Inventory::PLACEMENT_IMAGES.collect{|placement, size|
        inventory_placement(holder, placement, size, options)
      }.join(""),
      :id => :placements
    )
  end

  def inventory_use_label(inventory)
    limit_label = if inventory.usage_limit.nil?
      fb_i(t("inventories.index.buttons.use.unlimited"))
    elsif inventory.usage_limit > 1
      fb_i(t("inventories.index.buttons.use.limited", :left => inventory.uses_left, :limit => inventory.usage_limit))
    end

    fb_i(t("inventories.index.buttons.use.base") + fb_it(:usage_limit,  limit_label ))
  end
end
