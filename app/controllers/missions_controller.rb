class MissionsController < ApplicationController
  def fulfill
    @mission ||= Mission.find(params[:id])

    @result = current_character.missions.fulfill!(@mission)

    @missions = fetch_missions if @result.level_rank.just_completed?

    render :fulfill, :layout => "ajax"
  end
  
  def help
    request_data = encryptor.decrypt(params[:key])
    
    @requester = Character.find_by_id(request_data[:character_id])
    @mission = Mission.find(params[:id])

    @help_result = current_character.mission_help_results.create(:requester => @requester, :mission => @mission)
  end
  
  protected
  
  def fetch_missions
    current_character.mission_groups.current.missions.with_state(:visible).visible_for(current_character)
  end
end
