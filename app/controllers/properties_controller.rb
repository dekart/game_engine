class PropertiesController < ApplicationController
  def new
    @property_types = PropertyType.available_in(:shop).available_for(current_character)
  end

  def create
    @property_type = PropertyType.find(params[:property_type_id])

    @property = current_character.properties.create(:property_type => @property_type)

    unless @property.new_record?
      goal(:property_buy, @property_type.id)
    end

    current_character.recalculate_income
    
    render :action => :create, :layout => "ajax"
  end

  def index
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
