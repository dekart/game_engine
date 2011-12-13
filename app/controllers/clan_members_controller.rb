class ClanMembersController < ApplicationController
  def destroy
    @clan_member = ClanMember.find_by_character_id(params[:id])
    @clan_member.destroy
    
    redirect_from_iframe(clans_url(:canvas => true))
  end
end
