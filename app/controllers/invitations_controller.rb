class InvitationsController < ApplicationController
  def accept
    @invitation = Invitation.find(params[:id])

    @invitation.accept!

    render :action => :accept, :layout => false
  end

  def decline
    @invitation = Invitation.find(params[:id])

    @invitation.decline!

    render :action => :decline, :layout => false
  end
end
