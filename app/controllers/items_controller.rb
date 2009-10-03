class ItemsController < ApplicationController
  def index
    @item_group = parents.item_group || ItemGroup.first(:order => :position)

    @items = @item_group.items.available_in(:shop).available_for(current_character).paginate(
      :page     => params[:page],
      :per_page => Configuration[:item_show_basic]
    )
    
    @special_items = @item_group.items.available_in(:special).available_for(current_character).all(
      :limit => Configuration[:item_show_special],
      :order => "level DESC"
    )

    @next_item = @item_group.items.next_for(current_character).first
  end
end
