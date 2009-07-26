class Admin::StylesheetsController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @stylesheets = Stylesheet.all
  end

  def new
    @stylesheet = Stylesheet.new
  end

  def create
    @stylesheet = Stylesheet.new(params[:stylesheet])

    if @stylesheet.save
      redirect_to admin_stylesheets_path
    else
      render :action => :new
    end
  end

  def edit
    @stylesheet = Stylesheet.find(params[:id])
  end

  def update
    @stylesheet = Stylesheet.find(params[:id])

    if @stylesheet.update_attributes(params[:stylesheet])
      redirect_to admin_stylesheets_path
    else
      render :action => :edit
    end
  end

  def destroy
    @stylesheet = Stylesheet.find(params[:id])

    @stylesheet.destroy

    redirect_to admin_stylesheets_path
  end

  def use
    @stylesheet = Stylesheet.find(params[:id])

    @stylesheet.use!

    redirect_to :action => :index
  end
end
