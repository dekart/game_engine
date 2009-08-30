class InvitationsController < ApplicationController
  def accept
    @invitation = Invitation.find(params[:id])

    if @invitation.accept!
      send_notification(@invitation)

      goal(:invitation_accept, @invitation.sender_id)
    end

    render :action => :accept, :layout => false
  end

  def ignore
    @invitation = Invitation.find(params[:id])

    if @invitation.ignore!
      goal(:invitation_ignore, @invitation.sender_id)
    end

    render :action => :ignore, :layout => false
  end

  def show
    @character = Character.find(params[:id])

    if @character == current_character
      redirect_to root_url
    elsif current_character.friend_relations.established?(@character)
      flash[:notice] = t("invitations.show.messages.already_joined")

      redirect_to root_url
    elsif not friend?(@character.user)
      flash[:error] = t("invitations.show.messages.only_friends")

      redirect_to root_url
    end
  end

  def update
    @character = Character.find(params[:id])
    
    Invitation.transaction do
      invitation = @character.user.invitations.build(:receiver_id => current_user.facebook_id)

      if invitation.save
        if invitation.accept!
          send_notification(invitation)
          
          goal(:invitation_link_accept, @character.id)
        else
          goal(:invitation_link_ignore, @character.id)
        end
      end
    end

    redirect_to root_url
  end

  protected

  def send_notification(invitation)
    Delayed::Job.enqueue Jobs::InvitationNotification.new(facebook_session, invitation.id)
  end
end
