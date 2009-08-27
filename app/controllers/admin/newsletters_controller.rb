class Admin::NewslettersController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @newsletters = Newsletter.paginate(:page => params[:page], :order => "created_at DESC")
  end

  def new
    @newsletter = Newsletter.new
  end

  def create
    @newsletter = Newsletter.new(params[:newsletter])

    if @newsletter.save
      redirect_to admin_newsletters_path
    else
      render :action => :new
    end
  end

  def edit
    @newsletter = Newsletter.find(params[:id])
  end

  def update
    @newsletter = Newsletter.find(params[:id])

    if @newsletter.update_attributes(params[:newsletter])
      redirect_to admin_newsletters_path
    else
      render :action => :edit
    end
  end

  def destroy
    @newsletter = Newsletter.find(params[:id])

    @newsletter.destroy

    redirect_to admin_newsletters_path
  end

  def deliver
    @newsletter = Newsletter.find(params[:id])

    @newsletter.start_delivery!

    redirect_to admin_newsletters_path
  end

  def pause
    @newsletter = Newsletter.find(params[:id])

    @newsletter.pause_delivery!

    redirect_to admin_newsletters_path
  end
end
