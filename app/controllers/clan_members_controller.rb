class ClanMembersController < ApplicationController
  def destroy
    current_character.clan_member.destroy
    
    redirect_from_iframe(clans_url(:canvas => true))
  end
  
  def delete_member
    @member = ClanMember.find(params[:id])
    @clan   = @member.clan
    
    @member.delete!
    
    @clan_members = @clan.clan_members
    
    render :layout => "ajax"
  end
end
