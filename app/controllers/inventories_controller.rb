class InventoriesController < ApplicationController
  def create
    @item = Item.available_in(:shop).find(params[:item_id])

    @inventory = current_character.inventories.create(:item => @item)

    render :action => :create, :layout => "ajax"
  end

  def destroy
    @inventory = current_character.inventories.find(params[:id])

    @inventory.sell

    render :action => :destroy, :layout => "ajax"
  end

  def index
    @inventories = current_character.inventories
  end

  def place
    @inventory = current_character.inventories.find(params[:id])

    @inventory.place_to(params[:placement])

    render :partial => "inventories/placements", :locals => {:character => current_character}
  end

  def use
    @inventory = current_character.inventories.find(params[:id])

    @inventory.use

    render :action => :use, :layout => "ajax"
  end
end
