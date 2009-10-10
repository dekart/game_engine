class PropertiesController < ApplicationController
  def create
    @property_type = PropertyType.find(params[:property_type_id])
    
    @property = current_character.properties.buy!(@property_type)

    @properties = current_character.properties
    
    render :action => :create, :layout => "ajax"
  end

  def index
    @properties = current_character.properties
  end

  def destroy
    @property_type = PropertyType.find(params[:id])

    @property = current_character.properties.sell!(@property_type)

    @properties = current_character.properties

    render :action => :destroy, :layout => "ajax"
  end
end
