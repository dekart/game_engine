class ClanMembersController < ApplicationController
  def destroy
    current_character.clan_member.destroy
    
    #redirect_to clans_url
    redirect_from_iframe(clans_path(:canvas => true))
  end
  
  def delete
    member = current_character.clan.clan_members.find(params[:id])
    
    member.delete_by_creator! if current_character.clan_member.creator?
     
    @clan = Clan.find(member.clan_id)
  end
end
