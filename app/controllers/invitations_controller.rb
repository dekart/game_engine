class InvitationsController < ApplicationController
  def accept
    @invitation = Invitation.find(params[:id])

    if @invitation.accept!
      send_notification(@invitation)
    end

    render :action => :accept, :layout => false
  end

  def ignore
    @invitation = Invitation.find(params[:id])

    @invitation.ignore!

    render :action => :ignore, :layout => false
  end

  def show
    @id, @secret = params[:id].split("-")

    @character = Character.find(@id)

    if @secret != @character.secret
      unless friend?(@character.user)
        flash[:error] = t("invitations.show.messages.only_friends")

        redirect_to root_url
      end
    elsif @character == current_character
      redirect_to root_url
    elsif current_character.friend_relations.established?(@character)
      flash[:notice] = t("invitations.show.messages.already_joined")

      redirect_to root_url
    end
  end

  def update
    @character = Character.find(params[:id])
    
    Invitation.transaction do
      invitation = @character.user.invitations.find_or_create_by_receiver_id(current_user.facebook_id)

      if invitation.accept!
        send_notification(invitation)
      end
    end

    redirect_to root_url
  end

  protected

  def send_notification(invitation)
    Delayed::Job.enqueue Jobs::InvitationNotification.new(facebook_session, invitation.id)
  end
end
