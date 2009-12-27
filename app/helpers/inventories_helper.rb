module InventoriesHelper
  def inventory_use_label(inventory)
    limit_label = if inventory.usage_limit.nil?
      fb_i(t("inventories.use.button.unlimited"))
    elsif inventory.usage_limit > 1
      fb_i(t("inventories.use.button.limited", :left => inventory.uses_left, :limit => inventory.usage_limit))
    end

    fb_i(t("inventories.use.button.base") + fb_it(:usage_limit,  limit_label ))
  end
end
