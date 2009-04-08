class InventoriesController < ApplicationController
  def create
    @item = Item.find(params[:item_id])

    @inventory = current_character.inventories.create(:item => @item)

    render :action => :create, :layout => "ajax"
  end

  def destroy
    @inventory = current_character.inventories.find(params[:id])

    @inventory.destroy

    render :action => :destroy, :layout => "ajax"
  end

  def index
    @inventories = current_character.inventories
  end

  def apply
    @inventory = current_character.inventories.find(params[:id])

    @inventory.update_attribute(:placement, params[:placement])

    render :partial => "inventories/placements", :locals => {:character => current_character}
  end
end
