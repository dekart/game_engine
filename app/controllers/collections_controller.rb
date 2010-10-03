class CollectionsController < ApplicationController
  def index
    @collections = Collection.with_state(:visible)
  end

  def update
    @collection = Collection.find(params[:id])
    
    @result = current_character.collections.apply!(@collection)

    render :layout => "ajax"
  end
end
