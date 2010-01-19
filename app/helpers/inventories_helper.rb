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
end
