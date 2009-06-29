class RelationsController < ApplicationController
  def index
    @relations = current_character.relations.paginate(:page => params[:page], :per_page => 10)
  end

  def destroy
    @target_character = Character.find(params[:id])

    Relation.destroy_between(current_character, @target_character)

    redirect_to relations_path
  end
end
