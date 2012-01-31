class MissionsController < ApplicationController
  def fulfill
    @mission ||= Mission.available_for(current_character).find(params[:id])

    @result = current_character.missions.fulfill!(@mission)
        
    if @result.level_rank.just_completed?
      @missions = current_character.mission_groups.current.missions.available_for(current_character)
    end
  end
 
  def help
    if params[:key].present?
      request_data = encryptor.decrypt_and_verify(params[:key])
    
      @requester = Character.find_by_id(request_data[:character_id])
      @mission = Mission.find(request_data[:mission_id])
      
      @help_result = current_character.mission_help_results.create(:requester => @requester, :mission => @mission)
    else
      redirect_from_iframe root_url(:canvas => true) 
    end
  end
  
  def collect_help_reward
    @basic_money, @experience = current_character.mission_helps.collect_reward!
    
    render :layout => 'ajax'
  end
end
