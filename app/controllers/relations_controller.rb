class RelationsController < ApplicationController
  def new
    @app_users = current_character.friend_filter.app_users.to_set
    @recommended = current_character.friend_filter.for_invitation(Setting.i(:relation_for_invitation_limit))
  end
  
  def create
    @character = Character.find(params[:character_id])
    
    current_character.friend_relations.establish!(@character)
  end
  
  def index
    if current_character.relations.size == 0 and params[:noredirect].nil?
      redirect_to new_relation_url
    else
      @relations = fetch_relations
    end
  end
  
  def show
    @character = Character.find_by_invitation_key(params[:id])

    if @character.nil? or @character == current_character
      redirect_to root_url
    elsif current_character.friend_relations.established?(@character)
      flash[:notice] = t("relations.show.messages.already_joined")

      redirect_to root_url
    elsif Setting.b(:relation_friends_only) && !friend_with?(@character)
      flash[:notice] = t("relations.show.messages.only_friends")

      redirect_to root_url
    end
  end
  
  def destroy
    @target = Character.find(params[:id])

    FriendRelation.destroy_between(current_character, @target)

    @relations = fetch_relations
  end

  protected

  def fetch_relations
    current_character.relations.paginate(
      :page     => params[:page],
      :per_page => Setting.i(:relation_show_limit)
    )
  end
  
  def friend_with?(character)
    current_user.friends_with?(character) ||
    current_facebook_user.api_client.get_connections('me', 'friends', :fields => 'id').collect{|f| f['id'].to_i }.include?(character.facebook_id)
  end
end
