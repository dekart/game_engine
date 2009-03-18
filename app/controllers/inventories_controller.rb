class InventoriesController < ApplicationController
  def create
    @item = Item.find(params[:item_id])

    @inventory = current_character.inventories.create(:item => @item)

    render :action => :create, :layout => false
  end

  def destroy
    @inventory = Inventory.find(params[:id])

    @inventory.destroy

    render :action => :destroy, :layout => false
  end

  def index
    @inventories = current_character.inventories
  end
end
