class ClanMembersController < ApplicationController
  def destroy
    current_character.clan_member.destroy
    
    redirect_from_iframe(clans_url(:canvas => true))
  end
  
  def delete_member
    member = ClanMember.find(params[:id])
    
    clan_id = member.clan.id
    
    member.delete!
     
    @clan = Clan.find(clan_id)

    render :layout => "ajax"
  end
end
