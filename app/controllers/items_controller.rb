class ItemsController < ApplicationController
  def index
    @item_groups = ItemGroup.visible_in_shop

    @current_group = parents.item_group || @item_groups.first

    @items = @current_group.items.in_shop_for(current_character)

    @next_item = @current_group.items.next_for(current_character).first

    if request.xhr?
      render :partial => "list", :items => @items, :layout => 'ajax'
    end
  end
  
  def show
    @item = Item.find(params[:id])
    
    render :layout => 'ajax'
  end
end
