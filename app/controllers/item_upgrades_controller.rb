class ItemUpgradesController < ApplicationController

  def show
    @inventory = current_character.inventories.find(params[:id])

    @recipe = UpgradeRecipe.with_state(:visible).find_by_item_id(@inventory.item.id)

    @maximum_amount = maximum_amount(@inventory, @recipe)

    render :layout => "ajax"
  end
  
  def update
    @inventory = current_character.inventories.find(params[:id])

    @recipe = UpgradeRecipe.with_state(:visible).find_by_item_id(@inventory.item)

    @amount = params[:amount].to_i
    
    if @amount != 0 && @inventory.amount >= @amount && @recipe.use!(current_character, @amount)

      render :layout => "ajax"
    else
      @maximum_amount = maximum_amount(@inventory, @recipe)

      render :show, :layout => "ajax"
    end
  end
  
  def maximum_amount(inventory, recipe)
    [inventory.amount, current_character.upgrade_tokens / recipe.price].min
  end
end