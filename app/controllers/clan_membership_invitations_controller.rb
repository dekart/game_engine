class ClanMembershipInvitationsController < ApplicationController
  def destroy
    if current_character.clan_member.try(:creator?)
      @invitation = ClanMembershipInvitation.find(params[:id])
      @invitation.destroy
    end  
  end
  
  def update
    @invitation = current_character.clan_membership_invitations.find(params[:id])
    
    @invitation.accept!
    
    redirect_to clan_url(@invitation.clan)
  end

end
