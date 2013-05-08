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

    if count = options.delete(:count) and (count.is_a?(TrueClass) or count > 1)
      result << span_tag(count.is_a?(TrueClass) ? inventory.amount : count, "count #{format}")
    end

    result << item_image(inventory.item, format, options)

    (
      %{<div class="inventory_image">#{ result }</div>}
    ).html_safe
  end

  def inventories_grouped_by_item_group(inventories)
    inventories.group_by{|i| i.item.item_group}.sort{|a, b| a.first.position <=> b.first.position }
  end

  def inventories_exchangeable_grouped_by_item_group
    @inventories_exchangeable_grouped_by_item_group ||= begin
      inventories_grouped_by_item_group(current_character.inventories.exchangeable)
    end
  end

  def inventories_equippable_grouped_by_item_group
    @inventories_equippable_grouped_by_item_group ||= begin
      inventories_grouped_by_item_group(current_character.inventories.equippable)
    end
  end

  def inventory_placement_tag(inventory, placement, content = nil, &block)
    content = capture(&block) if block_given?

    result = (
      %{
        <div
          class="inventory"
          data-placements="#{ inventory.placements.join(",") }"
          data-equip="#{ equip_inventory_path(inventory.item) }"
          data-unequip="#{ unequip_inventory_path(inventory.item, :placement => placement) }"
          data-move="#{ move_inventory_path(inventory.item, :from_placement => placement) }"
        >#{ content }</div>
      }
    ).html_safe

    block_given? ? concat(result) : result
  end

  def inventory_group_placement(placement, &block)
    result = ""

    inventories = current_character.equipment.inventories_by_placement(placement).inject(Hash.new(0)) {|h, v| h[v] += 1; h}

    inventories.each_slice(2) do |slice|
      result << '<li>'

      slice.each do |inventory, count|
        result << inventory_placement_tag(inventory, placement, capture(inventory, count, &block))
      end

      result << '</li>'
    end

    result = (
      %{
        <div
          class="group_placement"
          data-placement="#{ placement }"
          data-free-slots="#{ current_character.equipment.available_capacity(placement) }"
        >
          <ul>#{ result }</ul>
        </div>
      }
    ).html_safe

    concat(result)
  end
end
