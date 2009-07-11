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
    @relation = current_character.relations.find_by_id(params[:relation_id]) if params[:relation_id]

    @inventory = current_character.inventories.find(params[:id])
    @inventory.place_to(params[:placement], @relation)

    render(
      :partial  => "inventories/placements",
      :locals   => {:holder => @relation || current_character}
    )
  end

  def use
    @inventory = current_character.inventories.find(params[:id])

    @inventory.use

    render :action => :use, :layout => "ajax"
  end

  def placements
    @holder = current_character.relations.find_by_id(params[:relation_id]) if params[:relation_id]
    @holder ||= current_character

    render :action => :placements, :layout => "ajax"
  end
end
