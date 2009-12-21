class Admin::BossesController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @bosses = Boss.paginate(:page => params[:page])
  end

  def new
    redirect_to new_admin_boss_group_path if MissionGroup.count == 0
    
    @boss = Boss.new

    if params[:boss]
      @boss.attributes = params[:boss]

      @boss.valid?
    end
  end

  def create
    @boss = Boss.new(params[:boss])

    if @boss.save
      redirect_to admin_bosses_url(:canvas => true)
    else
      redirect_to new_admin_boss_url(:boss => params[:boss], :canvas => true)
    end
  end

  def edit
    @boss = Boss.find(params[:id])

    if params[:boss]
      @boss.attributes = params[:boss]

      @boss.valid?
    end
  end

  def update
    @boss = Boss.find(params[:id])

    if @boss.update_attributes(params[:boss].reverse_merge(:requirements => nil, :payouts => nil))
      redirect_to admin_bosses_url(:canvas => true)
    else
      redirect_to edit_admin_boss_url(:boss => params[:boss], :canvas => true)
    end
  end

  def destroy
    @boss = Boss.find(params[:id])

    @boss.destroy

    redirect_to :action => :index
  end
end
