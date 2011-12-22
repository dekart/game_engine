class ClanMembershipInvitationsController < ApplicationController
  def destroy
    if current_character.clan_member.try(:creator?)
      @invitation = ClanMembershipInvitation.find(params[:id])
      @invitation.destroy
    end  
  end
  
  def update
    @invitation = ClanMembershipInvitation.find(params[:id])
    
    @invitation.accept!
    
    redirect_from_iframe(clan_url(@invitation.clan, :canvas => true))
  end

end
