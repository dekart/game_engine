class PropertiesController < ApplicationController
  def index
    @properties = current_character.properties
  end

  def create
    @property_type = PropertyType.available_in(:shop, :special).available_for(current_character).
      find(params[:property_type_id])

    @property = current_character.properties.buy!(@property_type)

    if @property.errors.empty?
      EventLoggingService.log_event(:property_bought, @property)
    end

    @properties = current_character.properties(true)

    render :create, :layout => "ajax"
  end

  def upgrade
    @property = current_character.properties.find(params[:id])

    @property.upgrade!

    if @property.errors.empty?
      EventLoggingService.log_event(:property_upgraded, @property)
    end

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

    if @result
      if !@property.nil?
        EventLoggingService.log_event(:property_income_collected, @property, @result)
      else
        EventLoggingService.log_event(:properties_income_collected, @properties, @result)
      end
    end

    render :collect_money, :layout => "ajax"
  end

end
