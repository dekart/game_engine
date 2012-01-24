class Admin::UpgradeRecipesController < Admin::BaseController
  def index
    @recipes = UpgradeRecipe.without_state(:deleted)
  end

  def new
    @recipe = UpgradeRecipe.new
  end

  def create
    @recipe = UpgradeRecipe.new(params[:upgrade_recipe])

    if @recipe.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_upgrade_recipes_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @recipe = UpgradeRecipe.find(params[:id])
  end

  def update
    @recipe = UpgradeRecipe.find(params[:id])
    previous = @recipe.item

    if @recipe.update_attributes(params[:upgrade_recipe])
      flash[:success] = t(".success")

      if @recipe.state == "visible"
        @recipe.reload

        if previous != @recipe.item
          @recipe.item.upgradable = true
          @recipe.item.save if @recipe.item.changed?

          if UpgradeRecipe.with_state(:visible).select{|rec| rec != @recipe && rec.item == previous}.empty?
            previous.upgradable = false
            previous.save if previous.changed?
          end
        end
      end

      unless_continue_editing do
        redirect_to admin_upgrade_recipes_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    @recipe = UpgradeRecipe.find(params[:id])
    
    state_change_action(@recipe) do |state|
      case state
      when :visible
        @recipe.publish if @recipe.can_publish?
      when :hidden
        @recipe.hide if @recipe.can_hide?
      when :deleted
        @recipe.mark_deleted if @recipe.can_mark_deleted?
      end
    end
  end
end
