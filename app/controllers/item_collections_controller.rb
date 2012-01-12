class ItemCollectionsController < ApplicationController
  def index
    @collections = ItemCollection.with_state(:visible).available_by_level(current_character).all
  end

  def update
    @collection = ItemCollection.find(params[:id])

    @result = current_character.collections.apply!(@collection)

    render :layout => "ajax"
  end

end
