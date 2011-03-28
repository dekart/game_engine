class ItemCollectionsController < ApplicationController
  def index
    @collections = ItemCollection.with_state(:visible)
  end

  def update
    @collection = ItemCollection.find(params[:id])

    @result = current_character.collections.apply!(@collection)

    if @result.applied
      EventLoggingService.log_event(collection_event_data(:collection_applied, current_character, @collection))
    end

    render :layout => "ajax"
  end

  protected

  def collection_event_data(event_type, character, collection)
    {
      :event_type => event_type,
      :character_id => character.id,
      :level => character.level,
      :reference_id => collection.id,
      :reference_type => "Collection",
      :occurred_at => Time.now
    }.to_json
  end
end
