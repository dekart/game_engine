module InventoriesHelper
  def inventory_additonal_slots_note
    free_slots = current_character.equipment.placement_free_slots(:additional)
    
    yield(free_slots).html_safe!
  end

  def inventory_free_slots_note
    free_slots = current_character.equipment.free_slots

    if free_slots > 0 and current_character.inventories.equippable.size > 0
      yield(free_slots)
    end
  end
end
