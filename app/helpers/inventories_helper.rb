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
  
  def boosts_for(type, destination)
    render("inventories/boosts", 
      :type => type, 
      :destination => destination
    )
  end
  
  def boost_dom_id(boost, destination)
    item = boost.respond_to?(:item) ? boost.item : boost
    
    dom_id(item, "boost_#{item.boost_type}_#{destination}")
  end

  def inventory_item_image(inventory, format, options = {})
    result = ""

    if count = options.delete(:count)
      result << '<span class="count %s">%s</span>' % [
        format,
        count.is_a?(TrueClass) ? inventory.amount : count
      ]
    end

    result << item_image(inventory, format, options)

    (
      '<div class="inventory_image">%s</div>' % result
    ).html_safe
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

  def inventory_placement_tag(inventory, placement, content = nil, &block)
    content = capture(&block) if block_given?

    result = (
      '<div class="inventory" data-placements="%s" data-equip="%s" data-unequip="%s" data-move="%s">%s</div>' % [
        inventory.placements.join(","),
        equip_inventory_path(inventory),
        unequip_inventory_path(inventory, :placement => placement),
        move_inventory_path(inventory, :from_placement => placement),
        content
      ]
    ).html_safe

    block_given? ? concat(result) : result
  end

  def inventory_group_placement(placement, &block)
    result = ""

    inventories = current_character.equipment.inventories_by_placement(placement).inject(Hash.new(0)) {|h, v| h[v] += 1; h}

    inventories.each_pair do |inventory, count|
      result << '<li>%s</li>' % inventory_placement_tag(inventory, placement, capture(inventory, count, &block))
    end

    result = (
      '<div class="group_placement" data-placement="%s" data-free-slots="%s"><ul class="carousel-container">%s</ul></div>' % [
        placement,
        current_character.equipment.available_capacity(placement),
        result
      ]
    ).html_safe

    concat(result)
  end
end
