class Admin::MissionsController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @missions = Mission.all(
      :include  => :mission_group,
      :order    => "mission_groups.level"
    ).paginate(:page => params[:page])
  end

  def new
    redirect_to new_admin_mission_group_path if MissionGroup.count == 0

    @mission = Mission.new
  end

  def create
    @mission = Mission.new(params[:mission])

    if @mission.save
      redirect_to admin_missions_url(:canvas => true)
    else
      render :action => :new
    end
  end

  def edit
    @mission = Mission.find(params[:id])
  end

  def update
    @mission = Mission.find(params[:id])

    if @mission.update_attributes(params[:mission])
      redirect_to admin_missions_url(:canvas => true)
    else
      render :action => :edit
    end
  end

  def destroy
    @mission = Mission.find(params[:id])

    @mission.destroy

    redirect_to :action => :index
  end
end
