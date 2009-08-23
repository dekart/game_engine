class ItemsController < ApplicationController
  def index
    @item_group = parents.item_group || ItemGroup.first(:order => :position)

    @items = @item_group.items.available_in(:shop).available_for(current_character).paginate(
      :page     => params[:page],
      :per_page => 10
    )
    
    @special_items = @item_group.items.available_in(:special).available_for(current_character).all(:limit => 3, :order => "level DESC")
  end
end
