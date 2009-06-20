class Admin::MissionGroupsController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @groups = MissionGroup.all(:order => :level)
  end

  def new
    @group = MissionGroup.new
  end

  def create
    @group = MissionGroup.new(params[:mission_group])

    if @group.save
      redirect_to :action => :index
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
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

  def destroy
    @group = MissionGroup.find(params[:id])

    @group.destroy

    redirect_to :action => :index
  end
end
