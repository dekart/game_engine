class CollectionsController < ApplicationController
  def index
    @collections = Collection.with_state(:visible)
  end
end
