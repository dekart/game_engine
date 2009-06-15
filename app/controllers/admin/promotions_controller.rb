class Admin::PromotionsController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @promotions = Promotion.paginate(:page => params[:page])
  end

  def new
    @promotion = Promotion.new
  end

  def create
    @promotion = Promotion.new(params[:promotion])

    if @promotion.save
      redirect_to admin_promotions_path
    else
      render :action => :new
    end
  end

  def edit
    @promotion = Promotion.find(params[:id])
  end

  def update
    @promotion = Promotion.find(params[:id])

    if @promotion.update_attributes(params[:promotion])
      redirect_to admin_promotions_path
    else
      render :action => :edit
    end
  end

  def destroy
    @promotion = Promotion.find(params[:id])

    @promotion.destroy

    redirect_to admin_promotions_path
  end
end
