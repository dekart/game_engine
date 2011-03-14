class ItemCollectionsController < ApplicationController
  def index
    @collections = ItemCollection.with_state(:visible)
  end

  def update
    @collection = ItemCollection.find(params[:id])

    @result = current_character.collections.apply!(@collection)

    if @result.applied
      EventLoggingService.log_event(:collection_applied, collection_event_data(current_character, @collection))
    end

    render :layout => "ajax"
  end

  protected

  def collection_event_data(character, collection)
    {
      :character_id => character.id,
      :character_level => character.level,
      :collection_id => collection.id
    }.to_json
  end
end
