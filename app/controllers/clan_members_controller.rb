class ClanMembersController < ApplicationController
  def destroy
    current_character.clan_member.destroy
    
    redirect_to clans_url
  end
  
  def delete
    member = ClanMember.find(params[:id])
    
    member.delete_by_creator!
     
    @clan = Clan.find(member.clan_id)
  end
end
