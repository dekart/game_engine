class ItemUpgradesController < ApplicationController
  def show
    @inventory = current_character.inventories.find(params[:id])

    @recipe = UpgradeRecipe.with_state(:visible).find_by_item_id(@inventory.item.id)

    render :layout => "ajax"
  end
  
  def update
    @inventory = current_character.inventories.find(params[:id])

    @recipe = UpgradeRecipe.with_state(:visible).find_by_item_id(@inventory.item)

    @amount = params[:inventory][:amount]
    
    render :layout => "ajax"
  end
end