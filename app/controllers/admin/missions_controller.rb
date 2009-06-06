class Admin::MissionsController < ApplicationController
  layout "layouts/admin/application"

  def index
    @missions = Mission.all(:order => :level).paginate(:page => params[:page])
  end

  def new
    @mission = Mission.new
  end

  def create
    @mission = Mission.new(params[:mission])

    if @mission.save
      redirect_to :action => :index
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
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

  def destroy
    @mission = Mission.find(params[:id])

    @mission.destroy

    redirect_to :action => :index
  end

  def add_requirement
    @requirement = Requirements::Base.by_name(params[:type]).new(nil)

    render :action => :add_requirement, :layout => "admin/ajax"
  end

  def add_payout
    @payout = Payouts::Base.by_name(params[:type]).new(nil)

    render :action => :add_payout, :layout => "admin/ajax"
  end
end
