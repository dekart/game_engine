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

    @result = @inventory.use!

    render :action => :use, :layout => "ajax"
  end

  def equipment
  end

  def equip
    @inventory = current_character.inventories.find(params[:id])

    current_character.equipment.equip!(@inventory, params[:placement])

    render :layout => "ajax"
  end

  def unequip
    @inventory = current_character.inventories.find(params[:id])

    current_character.equipment.unequip!(@inventory, params[:placement])

    render :action => "equip", :layout => "ajax"
  end
end
