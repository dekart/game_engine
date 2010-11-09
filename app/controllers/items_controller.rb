class ItemsController < ApplicationController
  def index
    @item_groups = ItemGroup.with_state(:visible).visible_in_shop

    @current_group = parents.item_group || @item_groups.first(:order => :position)

    item_scope = @current_group.items.with_state(:visible).available.available_for(current_character)

    @items = item_scope.available_in(:shop).paginate(
      :page     => params[:page],
      :per_page => Setting.i(:item_show_basic)
    )

    @special_items = item_scope.available_in(:special).all(
      :limit => Setting.i(:item_show_special),
      :order => "level DESC"
    )

    @next_item = @current_group.items.next_for(current_character).first
  end
end
