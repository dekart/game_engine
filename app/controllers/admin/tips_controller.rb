class Admin::TipsController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @tips = Tip.paginate(:page => params[:page])
  end

  def new
    @tip = Tip.new
  end

  def create
    @tip = Tip.new(params[:tip])

    if @tip.save
      redirect_to admin_tips_path
    else
      render :action => :new
    end
  end

  def edit
    @tip = Tip.find(params[:id])
  end

  def update
    @tip = Tip.find(params[:id])

    if @tip.update_attributes(params[:tip])
      redirect_to admin_tips_path
    else
      render :action => :edit
    end
  end

  def destroy
    @tip = Tip.find(params[:id])

    @tip.destroy

    redirect_to admin_tips_path
  end
end
