class ItemsController < ApplicationController
  def index
    @item_group = parents.item_group || ItemGroup.first(:order => :position)

    @items = @item_group.items.shop.available_for(current_character)
  end
end
