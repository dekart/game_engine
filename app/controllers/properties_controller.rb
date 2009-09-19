class PropertiesController < ApplicationController
  def create
    @property_type = PropertyType.find(params[:property_type_id])
    
    @property = current_character.properties.buy!(@property_type)

    goal(:property_buy, @property_type.id) if @property.valid?
    
    render :action => :create, :layout => "ajax"
  end

  def index
    @property_types = PropertyType.available_in(:shop).available_for(current_character)
    
    @properties = current_character.properties.paginate(:page => params[:page])
  end

  def destroy
    @property_type = PropertyType.find(params[:id])

    @property = current_character.properties.sell!(@property_type)

    goal(:property_sell, @property_type.id)

    render :action => :destroy, :layout => "ajax"
  end
end
