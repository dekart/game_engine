class Admin::MissionGroupsController < Admin::BaseController
  def index
    @groups = MissionGroup.without_state(:deleted)
  end

  def new
    @group = MissionGroup.new(params[:mission_group])
  end

  def create
    @group = MissionGroup.new(params[:mission_group])

    if @group.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_mission_groups_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @group = MissionGroup.find(params[:id])
  end

  def update
    @group = MissionGroup.find(params[:id])

    if @group.update_attributes(params[:mission_group].reverse_merge(:requirements => nil, :payouts => nil))
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_mission_groups_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    publish_hide_delete_states(MissionGroup.find(params[:id]))
  end

  def change_position
    change_position_action(MissionGroup.find(params[:id]))
  end
end
