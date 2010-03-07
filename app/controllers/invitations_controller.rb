class InvitationsController < ApplicationController
  def accept
    @invitation = Invitation.find(params[:id])

    @invitation.accept!

    render :text => t("invitations.accept.message"), :layout => false
  end

  def ignore
    @invitation = Invitation.find(params[:id])

    @invitation.ignore!

    render :text => t("invitations.ignore.message"), :layout => false
  end

  def show
    @id, @secret = params[:id].split("-")

    @character = Character.find(@id)

    if @secret != @character.secret
      unless friend?(@character.user)
        flash[:error] = t("invitations.show.messages.only_friends")

        redirect_to landing_url
      end
    elsif @character == current_character
      redirect_to landing_url
    elsif current_character.friend_relations.established?(@character)
      flash[:notice] = t("invitations.show.messages.already_joined")

      redirect_to landing_url
    end
  end

  def update
    @character = Character.find(params[:id])
    
    Invitation.transaction do
      invitation = @character.user.invitations.find_or_create_by_receiver_id(current_user.facebook_id)

      if invitation.accept!
        flash[:success] = t("invitations.accept.message")
      end
    end

    redirect_to landing_url
  end
end
