class PropertiesController < ApplicationController
  def index
    @properties = current_character.properties
  end

  def create
    @property_type = PropertyType.available_in(:shop, :special).available_for(current_character).
      find(params[:property_type_id])

    @property = current_character.properties.buy!(@property_type)

    @properties = current_character.properties(true)

    render :action => :create, :layout => "ajax"
  end

  def upgrade
    @property = current_character.properties.find(params[:id])

    @property.upgrade

    @properties = current_character.properties(true)

    render :action => :upgrade, :layout => "ajax"
  end
end
