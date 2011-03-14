class PropertiesController < ApplicationController
  def index
    @properties = current_character.properties
  end

  def create
    @property_type = PropertyType.available_in(:shop, :special).available_for(current_character).
      find(params[:property_type_id])

    @property = current_character.properties.buy!(@property_type)

    if @property.errors.empty?
      EventLoggingService.log_event(:property_bought, property_event_data(@property))
    end

    @properties = current_character.properties(true)

    render :create, :layout => "ajax"
  end

  def upgrade
    @property = current_character.properties.find(params[:id])

    @property.upgrade!

    if @property.errors.empty?
      EventLoggingService.log_event(:property_upgraded, property_event_data(@property))
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
      properties = @property.nil? ? @properties : [@property]
      properties.each do |property|
        EventLoggingService.log_event(:properties_income_collected, property_event_data(property))
      end
    end

    render :collect_money, :layout => "ajax"
  end

  protected

  def property_event_data(property)
    {
      :character_id => property.character.id,
      :character_level => property.character.level,
      :property_id => property.id,
      :property_type_id => property.property_type.id,
      :property_level => property.level,
      :income => property.total_income
    }.to_json
  end
end
