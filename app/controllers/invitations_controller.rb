class InvitationsController < ApplicationController
  def accept
    @invitation = Invitation.find(params[:id])

    @invitation.accept!

    render :action => :accept, :layout => false
  end

  def ignore
    @invitation = Invitation.find(params[:id])

    @invitation.ignore!

    render :action => :ignore, :layout => false
  end
end
