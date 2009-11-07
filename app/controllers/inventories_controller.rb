class InventoriesController < ApplicationController
  def create
    @amount = params[:amount].to_i
    
    @item = Item.available.available_in(:shop, :special).available_for(current_character).find(params[:item_id])

    @inventory = current_character.inventories.buy!(@item, @amount)

    render :action => :create, :layout => "ajax"
  end

  def destroy
    @amount = params[:amount].to_i
    
    @item = Item.find(params[:id])

    @inventory = current_character.inventories.sell!(@item, @amount)

    render :action => :destroy, :layout => "ajax"
  end

  def index
    @inventories = current_character.inventories
  end

  def use
    @inventory = current_character.inventories.find(params[:id])

    @inventory.use

    render :action => :use, :layout => "ajax"
  end
end
