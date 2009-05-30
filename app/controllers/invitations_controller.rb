class InvitationsController < ApplicationController
  def accept
    @invitation = Invitation.find(params[:id])

    if @invitation.accept!
      Delayed::Job.enqueue Jobs::InvitationNotification.new(facebook_session, @invitation.id)
    end

    render :action => :accept, :layout => false
  end

  def ignore
    @invitation = Invitation.find(params[:id])

    @invitation.ignore!

    render :action => :ignore, :layout => false
  end
end
