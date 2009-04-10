module InventoriesHelper
  def inventory_placement(character, placement)
    placement = placement.to_sym
    
    if inventory = character.inventories.placed.detect{|i| i.placement.to_sym == placement }
      image_tag(inventory.item.image.url(placement), :class => placement)
    end
  end
end
