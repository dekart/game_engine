class ClanMembersController < ApplicationController
  def destroy
    current_character.clan_member.destroy
    
    redirect_from_iframe(clans_url(:canvas => true))
  end
  
  def delete_member
    member = ClanMember.find(params[:id])
    
    member.delete_by_creator!
     
    @clan = Clan.find(member.clan_id)

    render :layout => "ajax"
  end
end
