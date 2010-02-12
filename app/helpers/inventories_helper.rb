module InventoriesHelper
  def inventory_use_label(inventory)
    if inventory.usage_limit.nil?
      limit_label = t("inventories.use.button.unlimited")
    elsif inventory.usage_limit > 1
      limit_label = t("inventories.use.button.limited",
        :left   => inventory.uses_left,
        :limit  => inventory.usage_limit
      )
    end

    t("inventories.use.button.base", :limit => limit_label)
  end
  safe_helper :inventory_use_label

  def inventory_additonal_slots_note
    free_slots = current_character.equipment.placement_free_slots(:additional)
    
    yield(free_slots)
  end
  safe_helper :inventory_additonal_slots_note

  def inventory_free_slots_note
    free_slots = current_character.equipment.free_slots

    if free_slots > 0 and current_character.inventories.equippable.size > 0
      yield(free_slots)
    end
  end
end
