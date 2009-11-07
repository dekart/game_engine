class PropertiesController < ApplicationController
  def create
    @amount = params[:amount].to_i
    
    @property_type = PropertyType.available_in(:shop).available_for(current_character).find(params[:property_type_id])
    
    @property = current_character.properties.buy!(@property_type, @amount)

    @properties = current_character.properties
    
    render :action => :create, :layout => "ajax"
  end

  def index
    @properties = current_character.properties
  end

  def destroy
    @amount = params[:amount].to_i
    
    @property_type = PropertyType.find(params[:id])

    @property = current_character.properties.sell!(@property_type, @amount)

    @properties = current_character.properties

    render :action => :destroy, :layout => "ajax"
  end
end
