class ItemsController < ApplicationController
  def index
    @item_groups = ItemGroup.visible_in_shop

    @current_group = parents.item_group || @item_groups.first(:order => :position)

    @items = @current_group.items.in_shop_for(current_character).paginate(
      :page     => params[:page],
      :per_page => Setting.i(:item_show_basic)
    )

    @next_item = @current_group.items.next_for(current_character).first

    respond_to do |format|
      format.html
      format.js
    end
  end
end
