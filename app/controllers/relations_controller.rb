class RelationsController < ApplicationController
  def index
    @relations = current_character.relations.paginate(:page => params[:page])
  end

  def destroy
    @target = Character.find(params[:id])

    Relation.destroy_between(current_character, @target)

    redirect_to relations_path
  end
end
