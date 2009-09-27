class InventoriesController < ApplicationController
  def create
    @item = Item.available_for(current_character).find(params[:item_id])

    @inventory = current_character.inventories.buy!(@item)

    goal(:item_buy, @item.id)

    render :action => :create, :layout => "ajax"
  end

  def destroy
    @item = Item.find(params[:id])

    @inventory = current_character.inventories.sell!(@item)

    goal(:item_sell, @item.id)

    render :action => :destroy, :layout => "ajax"
  end

  def index
    @inventories = current_character.inventories
  end

  def use
    @inventory = current_character.inventories.find(params[:id])

    @inventory.use

    goal(:item_use, @inventory.item.id)

    render :action => :use, :layout => "ajax"
  end
end
