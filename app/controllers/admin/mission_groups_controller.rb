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
      redirect_to admin_mission_groups_url(:canvas => true)
    else
      new_admin_mission_group_url(:mission_group => params[:mission_group], :canvas => true)
    end
  end

  def edit
    @group = MissionGroup.find(params[:id])
  end

  def update
    @group = MissionGroup.find(params[:id])

    if @group.update_attributes(params[:mission_group])
      redirect_to admin_mission_groups_url(:canvas => true)
    else
      edit_admin_mission_group_url(@group, :mission_group => params[:mission_group], :canvas => true)
    end
  end

  def publish
    @group = MissionGroup.find(params[:id])

    @group.publish if @group.can_publish?

    redirect_to admin_mission_groups_url
  end

  def hide
    @group = MissionGroup.find(params[:id])

    @group.hide if @group.can_hide?

    redirect_to admin_mission_groups_url
  end

  def destroy
    @group = MissionGroup.find(params[:id])

    @group.mark_deleted if @group.can_mark_deleted?

    redirect_to admin_mission_groups_url
  end
end
