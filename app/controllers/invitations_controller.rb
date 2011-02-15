class InvitationsController < ApplicationController
  skip_landing_redirect :only => :show

  def accept
    @invitation = Invitation.find(params[:id])

    @invitation.accept!

    # TODO Unify invitation acceptance and ingnorance methods to use AJAX responses with analytics tracking
    render :text => t("invitations.accept.message"), :layout => false
  end

  def ignore
    @invitation = Invitation.find(params[:id])

    @invitation.ignore!

    render :text => t("invitations.ignore.message"), :layout => false
  end

  def show
    @character = Character.find_by_invitation_key(params[:id])

    if @character.nil? or @character == current_character
      redirect_from_iframe root_url(:canvas => true)
    elsif current_character.friend_relations.established?(@character)
      flash[:notice] = t("invitations.show.messages.already_joined")

      redirect_from_iframe root_url(:canvas => true)
    elsif Setting.b(:relation_friends_only) && !current_facebook_user.friends.detect{|f| f.id.to_i == @character.user.facebook_id }
      flash[:notice] = t("invitations.show.messages.only_friends")

      redirect_from_iframe root_url(:canvas => true)
    end
  end

  def update
    @character = Character.find(params[:id])

    Invitation.transaction do
      invitation = @character.user.invitations.find_or_create_by_receiver_id(current_user.facebook_id)

      invitation.accept!
    end

    render :layout => 'ajax'
  end
end
