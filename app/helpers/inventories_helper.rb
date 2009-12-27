module InventoriesHelper
  def inventory_use_label(inventory)
    limit_label = if inventory.usage_limit.nil?
      fb_i(t("inventories.use.button.unlimited"))
    elsif inventory.usage_limit > 1
      fb_i(t("inventories.use.button.limited", :left => inventory.uses_left, :limit => inventory.usage_limit))
    end

    fb_i(t("inventories.use.button.base") + fb_it(:usage_limit,  limit_label ))
  end

  def inventory_stream_dialog(inventory)
    show_stream_dialog(
      :attachment => {
        :caption => t("stories.inventory.title", :property => inventory.name, :app => t("app_name")),
        :media => inventory.image? ? [
          {
            :type => "image",
            :src  => image_path(inventory.image.url),
            :href => item_group_items_url(inventory.item_group)
          }
        ] : nil
      }
    )
  end
end
