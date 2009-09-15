class PropertiesController < ApplicationController
  def create
    @property_type = PropertyType.find(params[:property_type_id])
    
    @property = @property_type.buy(current_character)

    goal(:property_buy, @property_type.id) if @property.valid?

    current_character.recalculate_income
    
    render :action => :create, :layout => "ajax"
  end

  def index
    @property_types = PropertyType.available_in(:shop).available_for(current_character)
    
    @properties = current_character.properties.paginate(:page => params[:page])
  end

  def destroy
    @property = current_character.properties.find(params[:id])

    @property.sell

    goal(:property_sell, @property.property_type.id)

    current_character.reload

    render :action => :destroy, :layout => "ajax"
  end
end
