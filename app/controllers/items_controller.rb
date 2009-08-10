class ItemsController < ApplicationController
  def index
    @item_group = parents.item_group || ItemGroup.first(:order => :position)

    @items = @item_group.items.basic.available_in(:shop).available_for(current_character).paginate(
      :page     => params[:page],
      :per_page => 10
    )
    
    @special_item = @item_group.items.vip.available_in(:shop).available_for(current_character).first(:order => "RAND()")
  end
end
