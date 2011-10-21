module InventoriesHelper
  def inventory_additonal_slots_note
    yield(current_character.equipment.available_capacity(:additional))
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
      inventory.use_button_label.blank? ? t('inventories.list_inventory.buttons.use') : inventory.use_button_label
    )
  end

  def inventory_use_again_button(inventory)
    button(
      t('inventories.list_inventory.buttons.use_again',
        :use => inventory.use_button_label.blank? ? t('inventories.list_inventory.buttons.use') : inventory.use_button_label
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
  
  def inventories_grouped_by_item_group(inventories)
    inventories.group_by{|i| i.item_group}.sort{|a, b| a.first.position <=> b.first.position }
  end
  
  def inventories_exchangeable_grouped_by_item_group
    @inventories_exchangeable_grouped_by_item_group ||= begin
      inventories_grouped_by_item_group(current_character.inventories.exchangeable.all)
    end
  end
  
  def inventories_equippable_grouped_by_item_group
    @inventories_equippable_grouped_by_item_group ||= begin
      inventories_grouped_by_item_group(current_character.inventories.equippable.all)
    end
  end
  
  def inventories_equipment_with_count(placement)
    
  end
  
  def inventory_placement_tag(inventory, placement, &block)
    content_tag(:div, :class => :inventory, 
      :"data-placements" => inventory.placements.join(","),
      :"data-equip" => equip_inventory_path(inventory),
      :"data-unequip" => unequip_inventory_path(inventory, :placement => placement),
      :"data-move" => move_inventory_path(inventory, :from_placement => placement),
      &block
    )
  end
  
  def inventory_group_placement(placement, &block)
    result = ""
    
    inventories = current_character.equipment.inventories_by_placement(placement).inject(Hash.new(0)) {|h, v| h[v] += 1; h}
    
    inventories.each_pair do |inventory, count|
      result << content_tag(:li, 
        inventory_additional_placement_tag(inventory, capture(inventory, count, &block))
      )
    end
    
    result = content_tag(:div, 
      content_tag(:ul, result.html_safe, :class => "carousel-container"),
      :class => 'items group_placement', 
      :'data-placement' => placement, 
      :'data-free-slots' => current_character.equipment.available_capacity(placement)
    )
    
    concat(result)
  end
  
  def inventory_additional_placement_tag(inventory, content)
    content_tag(:div, 
      content,
      :class => :inventory, 
      :"data-placements" => inventory.placements.join(','),
      :"data-equip" => equip_inventory_path(inventory),
      :"data-unequip" => unequip_inventory_path(inventory, :placement => 'additional'),
      :"data-move" => move_inventory_path(inventory, :from_placement => 'additional')
    )
  end
  
end
