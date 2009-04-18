module InventoriesHelper
  def inventory_placement(character, placement, image_size)
    placement = placement.to_sym
    
    if inventory = character.inventories.placed.detect{|i| i.placement.to_sym == placement }
      image_tag(inventory.item.image.url(image_size), :class => placement)
    end
  end

  def inventory_use_label(inventory)
    limit_label = if inventory.usage_limit.nil?
      fb_i("(unlimited)")
    elsif inventory.usage_limit > 1
      "#{inventory.uses_left}/#{inventory.usage_limit}"
    end

    fb_i("Use " + fb_it(:usage_limit,  limit_label ))
  end
end
