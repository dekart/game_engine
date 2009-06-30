class Admin::PropertyTypesController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @types = PropertyType.paginate(:page => params[:page])
  end

  def new
    @type = PropertyType.new
  end

  def create
    @type = PropertyType.new(params[:property_type])

    if @type.save
      redirect_to admin_property_types_url(:canvas => true)
    else
      render :action => :new
    end
  end

  def edit
    @type = PropertyType.find(params[:id])
  end

  def update
    @type = PropertyType.find(params[:id])

    if @type.update_attributes(params[:property_type])
      redirect_to admin_property_types_url(:canvas => true)
    else
      render :action => :edit
    end
  end

  def destroy
    @type = PropertyType.find(params[:id])

    @type.destroy

    redirect_to :action => :index
  end
end
