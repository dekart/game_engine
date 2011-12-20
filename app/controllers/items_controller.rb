class ItemsController < ApplicationController
  def index
    @item_groups = ItemGroup.visible_in_shop

    @current_group = parents.item_group || @item_groups.first

    @items = @current_group.items.in_shop_for(current_character)

    @next_items = @current_group.items.next_for(current_character).all(:limit => 3)

    if request.xhr?
      render(
        :partial => "list", 
        :locals => {:items => @items, :next_items => @next_items}, 
        :layout => 'ajax'
      )
    end
  end
  
  def show
    @item = Item.find(params[:id])
    
    render :layout => 'ajax'
  end
end
