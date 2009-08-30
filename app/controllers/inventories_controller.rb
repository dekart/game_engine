class InventoriesController < ApplicationController
  def create
    @item = Item.available_for(current_character).find(params[:item_id])

    @inventory = current_character.inventories.create(:item => @item)

    goal(:item_buy, @item.id)

    render :action => :create, :layout => "ajax"
  end

  def destroy
    @inventory = current_character.inventories.find(params[:id])

    @inventory.sell

    goal(:item_sell, @inventory.item.id)

    render :action => :destroy, :layout => "ajax"
  end

  def index
    @inventories = current_character.inventories.available
  end

  def place
    @inventory = current_character.inventories.find(params[:id])

    @holder = relation_or_current_character

    @inventory.place_to(params[:placement], @holder)

    goal(:item_place, @inventory.item.id, params[:placement])

    current_character.reload

    render :action => :place, :layout => "ajax"
  end

  def use
    @inventory = current_character.inventories.find(params[:id])

    @inventory.use

    goal(:item_use, @inventory.item.id)

    render :action => :use, :layout => "ajax"
  end

  def placements
    @holder = relation_or_current_character

    render :action => :placements, :layout => "ajax"
  end

  def take_off
    @inventory = current_character.inventories.find(params[:id])

    @holder = @inventory.holder

    @inventory.take_off!

    goal(:item_take_off, @inventory.item.id)

    current_character.reload

    render :action => :take_off, :layout => "ajax"
  end

  protected

  def relation_or_current_character
    if params[:relation_id].blank?
      current_character
    else
      current_character.relations.find_by_id(params[:relation_id]) || current_character
    end
  end
end
