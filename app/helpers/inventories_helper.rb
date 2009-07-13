module InventoriesHelper
  def inventory_placement(character, placement, image_size, options = {})
    placement = placement.to_sym
    
    if inventory = character.holded_inventories.detect{|i| i.placement.to_sym == placement }
      code = fb_tag(:img,
        fb_ta(:src, image_path(inventory.image.url(image_size))) +
        fb_ta(:alt, fb_i(inventory.name)) +
        fb_ta(:title, fb_i(inventory.name))
      )
      
      if options[:controls]
        code << link_to_remote(
          fb_tag(:img,
            fb_ta(:src, image_path("icons/delete.gif")) +
            fb_ta(:alt, fb_i(t("inventories.placements.take_off"))) +
            fb_ta(:title, fb_i(t("inventories.placements.take_off")))
          ),
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
      fb_i(t("inventories.use.button.unlimited"))
    elsif inventory.usage_limit > 1
      fb_i(t("inventories.use.button.limited", :left => inventory.uses_left, :limit => inventory.usage_limit))
    end

    fb_i(t("inventories.use.button.base") + fb_it(:usage_limit,  limit_label ))
  end
end
