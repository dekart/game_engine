module InventoriesHelper
  def inventory_available_additonal_slots_count
    @inventory_available_additonal_slots_count ||= current_character.equipment.available_capacity(:additional)
  end
  
  def inventory_additonal_slots_note
    free_slots = inventory_available_additonal_slots_count

    yield(free_slots)
  end

  def inventory_free_slots_note
    return if Setting.b(:character_auto_equipment)

    free_slots = current_character.equipment.free_slots

    if free_slots > 0 and current_character.inventories.equippable.size > 0
      yield(free_slots)
    end
  end

  def inventory_use_button(inventory)
    button(
      inventory.use_button_label.blank? ? t('inventories.list.buttons.use') : inventory.use_button_label
    )
  end

  def inventory_use_again_button(inventory)
    button(
      t('inventories.list.buttons.use_again',
        :use => inventory.use_button_label.blank? ? t('inventories.list.buttons.use') : inventory.use_button_label
      )
    )
  end
  
  def boosts_list(boosts, type, destination, &block)
    active_boost_id = current_character.active_boosts[type][destination] if current_character.active_boosts[type]
    
    boosts.each do |boost|
      concat(
        capture(boost, active_boost_id == boost.id, &block)
      )
    end
  end
  
  def boost_dom_id(boost, destination)
    dom_id(boost, "boost_#{boost.boost_type}_#{destination}")
  end
  
  def inventory_item_image(inventory, format, options = {})
    result = "".html_safe
    if count = options.delete(:count)
      amount = count.is_a?(TrueClass) ? inventory.amount : count
      count = content_tag(:span, amount, :class => "count #{format}")
      
      result << count 
    end
    
    content_tag(:div, result << item_image(inventory, format, options), :class => 'inventory_image')
  end
  
  def inventories_grouped_by_item_group
    @inventories_grouped_by_item_group ||= begin
      current_character.inventories.equippable.all.group_by {|i| i.item_group }.sort{|a,b| a.first.name <=> b.first.name}
    end
  end
  
  def inventories_equipment_additional(character = current_character)
    @inventories_equipment_additional ||= begin
      character.equipment.inventories_by_placement(:additional).inject(Hash.new(0)) {|h, v| h[v] += 1; h}
    end
  end
  
end
