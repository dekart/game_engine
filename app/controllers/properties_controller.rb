class PropertiesController < ApplicationController
  def index
    @properties = current_character.properties
  end

  def create
    @property_type = PropertyType.available_in(:shop, :special).available_for(current_character).
      find(params[:property_type_id])

    @property, @result = current_character.properties.buy!(@property_type)

    @properties = current_character.properties(true)

    render :create, :layout => "ajax"
  end
  
  def hire
    @property = current_character.properties.find(params[:id])
    
    if request.put?
      @result = @property.hire_worker!(params[:hire_all])
    end
    
    render :layout => "ajax"
  end

  def upgrade
    @property = current_character.properties.find(params[:id])

    @result = @property.upgrade!

    @properties = current_character.properties(true)

    render :upgrade, :layout => "ajax"
  end

  def collect_money
    @properties = current_character.properties

    if params[:id]
      @property = current_character.properties.find(params[:id])

      @result = @property.collect_money!
    else
      @result = @properties.collect_money!
    end

    render :collect_money, :layout => "ajax"
  end

end
