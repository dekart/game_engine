class RelationsController < ApplicationController
  def index
    if current_character.relations.size == 0 and params[:noredirect].nil?
      redirect_to invite_users_path
    else
      @relations = fetch_relations
    end
  end

  def destroy
    @target = Character.find(params[:id])

    FriendRelation.destroy_between(current_character, @target)

    @relations = fetch_relations

    render :layout => 'ajax'
  end

  protected

  def fetch_relations
    current_character.relations.paginate(
      :page     => params[:page],
      :per_page => Setting.i(:relation_show_limit)
    )
  end
end
