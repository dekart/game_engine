class ClanMembershipInvitationsController < ApplicationController
  def destroy
    @invitation = ClanMembershipInvitation.find(params[:id])
    @invitation.destroy
  end

end
