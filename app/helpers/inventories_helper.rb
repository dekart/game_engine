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
    free_slots = current_character.equipment.placement_free_space(:additional)
    
    t("inventories.placements.additional.free_slots",
      :count        => free_slots,
      :count_label  => content_tag(:span, free_slots,
        :class => "value #{"zero" if free_slots == 0}"
      ),
      :relations    => link_to(Character.human_attribute_name("relations"), relations_path)
    )
  end
  safe_helper :inventory_additonal_slots_note
end
