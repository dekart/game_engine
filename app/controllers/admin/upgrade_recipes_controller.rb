class Admin::UpgradeRecipesController < Admin::BaseController
  def index
    @recipes = UpgradeRecipe.without_state(:deleted).paginate(:page => params[:page], :per_page => 50)
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

    if @recipe.update_attributes(params[:upgrade_recipe])
      flash[:success] = t(".success")

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
