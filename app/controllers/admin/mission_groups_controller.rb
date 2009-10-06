class Admin::MissionGroupsController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @groups = MissionGroup.all(:order => :level)
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

  def destroy
    @group = MissionGroup.find(params[:id])

    @group.destroy

    redirect_to :action => :index
  end
end
