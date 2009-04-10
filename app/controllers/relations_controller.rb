class RelationsController < ApplicationController
  def index
    @relations = current_character.relations.paginate(:page => params[:page])
  end
end
