class ClanMembersController < ApplicationController
  def destroy
    @clan_member = ClanMember.find_by_character_id(params[:id])
    @clan = @clan_member.clan
    
    @clan_member.destroy
    
    redirect_from_iframe clan_path(@clan)
  end
end
