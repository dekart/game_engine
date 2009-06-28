class ItemsController < ApplicationController
  def index
    @item_group = parents.item_group || ItemGroup.first(:order => :position)

    @basic_items = @item_group.items.shop.basic.available_for(current_character).paginate(
      :page     => params[:page],
      :per_page => 1
    )
    
    @vip_items = @item_group.items.shop.vip.available_for(current_character)
  end
end
