class ItemUpgradesController < ApplicationController

  def show
    @inventory = current_character.inventories.find(params[:id])

    @recipe = UpgradeRecipe.with_state(:visible).find_by_item_id(@inventory.item.id)

    @maximum_amount = [@inventory.amount, current_character.upgrade_tokens/@recipe.price].min

    render :layout => "ajax"
  end
  
  def update
    @inventory = current_character.inventories.find(params[:id])

    @recipe = UpgradeRecipe.with_state(:visible).find_by_item_id(@inventory.item)

    @amount = params[:amount].to_i
    
    if @inventory.amount >= @amount && @recipe.use!(current_character, @amount)
      render :layout => "ajax"
    else
      render :show, :layout => "ajax"
    end
  end
end