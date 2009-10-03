class RelationsController < ApplicationController
  def index
    if current_character.relations.size == 0
      redirect_to invite_users_path
    else
      @relations = current_character.relations.paginate(
        :page     => params[:page],
        :per_page => Configuration[:relation_show_limit]
      )
    end
  end

  def destroy
    @target_character = Character.find(params[:id])

    FriendRelation.destroy_between(current_character, @target_character)

    goal(:relation_destroy, @target_character.id)

    redirect_to relations_path
  end
end
