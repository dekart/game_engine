class ItemCollectionsController < ApplicationController
  def index
    @collections = ItemCollection.with_state(:visible)
  end

  def update
    @collection = ItemCollection.find(params[:id])

    @result = current_character.collections.apply!(@collection)

    if @result.applied
      EventLoggingService.log_event(:collection_applied, current_character, @collection)
    end

    render :layout => "ajax"
  end

end
