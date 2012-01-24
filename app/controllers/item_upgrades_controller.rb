class ItemUpgradesController < ApplicationController

  def show
    @inventory = current_character.inventories.find(params[:id])

    @recipe = UpgradeRecipe.with_state(:visible).find_by_item_id(@inventory.item.id)

    render :layout => "ajax"
  end
  
  def update
    @inventory = current_character.inventories.find(params[:id])

    @recipe = UpgradeRecipe.with_state(:visible).find_by_item_id(@inventory.item)

    @amount = params[:inventory][:amount].to_i
    
    if @inventory.amount >= @amount && @recipe.use!(current_character, @amount)
      render :layout => "ajax"
    else
      render :show, :layout => "ajax"
    end
  end
end