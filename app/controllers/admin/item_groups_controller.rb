class Admin::ItemGroupsController < Admin::BaseController
  def index
    @groups = ItemGroup.without_state(:deleted)
  end

  def new
    @group = ItemGroup.new
  end

  def create
    @group = ItemGroup.new(params[:item_group])

    if @group.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_item_groups_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @group = ItemGroup.find(params[:id])
  end

  def update
    @group = ItemGroup.find(params[:id])

    if @group.update_attributes(params[:item_group])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_item_groups_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(ItemGroup.find(params[:id]))
  end

  def change_position
    change_position_action(ItemGroup.find(params[:id]))
  end
end
