class Admin::PropertyTypesController < ApplicationController
  before_filter :admin_required

  layout "layouts/admin/application"

  def index
    @types = PropertyType.paginate(:page => params[:page])
  end

  def new
    @type = PropertyType.new

    if params[:property_type]
      @type.attributes = params[:property_type]
      
      @type.valid?
    end
  end

  def create
    @type = PropertyType.new(params[:property_type])

    if @type.save
      redirect_to admin_property_types_url(:canvas => true)
    else
      redirect_to new_admin_property_type_url(:property_type => params[:property_type], :canvas => true)
    end
  end

  def edit
    @type = PropertyType.find(params[:id])

    if params[:property_type]
      @type.attributes = params[:property_type]

      @type.valid?
    end
  end

  def update
    @type = PropertyType.find(params[:id])

    if @type.update_attributes(params[:property_type])
      redirect_to admin_property_types_url(:canvas => true)
    else
      redirect_to edit_admin_property_type_url(:property_type => params[:property_type], :canvas => true)
    end
  end

  def destroy
    @type = PropertyType.find(params[:id])

    @type.destroy

    redirect_to :action => :index
  end
end
