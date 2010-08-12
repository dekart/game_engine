class Admin::MissionGroupsController < Admin::BaseController
  def index
    @groups = MissionGroup.without_state(:deleted).all(:order => :level)
  end

  def new
    @group = MissionGroup.new(params[:mission_group])
  end

  def create
    @group = MissionGroup.new(params[:mission_group])

    if @group.save
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

    if @group.update_attributes(params[:mission_group])
      unless_continue_editing do
        redirect_to admin_mission_groups_path
      end
    else
      render :action => :edit
    end
  end

  def publish
    @group = MissionGroup.find(params[:id])

    @group.publish if @group.can_publish?

    redirect_to admin_mission_groups_path
  end

  def hide
    @group = MissionGroup.find(params[:id])

    @group.hide if @group.can_hide?

    redirect_to admin_mission_groups_path
  end

  def destroy
    @group = MissionGroup.find(params[:id])

    @group.mark_deleted if @group.can_mark_deleted?

    redirect_to admin_mission_groups_path
  end
end
