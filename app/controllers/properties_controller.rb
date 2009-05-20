class PropertiesController < ApplicationController
  def new
    @property_types = PropertyType.available_for(current_character)
  end

  def create
    @property_type = PropertyType.find(params[:property_type_id])

    @property = current_character.properties.create(:property_type => @property_type)
    
    render :action => :create, :layout => "ajax"
  end

  def index
    @properties = current_character.properties
  end

  def destroy
    @property = current_character.properties.find(params[:id])

    @property.sell

    render :action => :destroy, :layout => "ajax"
  end
end
