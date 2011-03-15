class MissionsController < ApplicationController
  def fulfill
    @mission ||= Mission.find(params[:id])

    @result = current_character.missions.fulfill!(@mission)
    
    if @result.success?
      EventLoggingService.log_event(mission_event_data(:mission_fulfilled, @result))
    end
    
    if @result.level_rank.just_completed?
      EventLoggingService.log_event(mission_event_data(:mission_completed, @result))
      
      @missions = fetch_missions
    end

    render :fulfill, :layout => "ajax"
  end
 
  def help
    request_data = encryptor.decrypt(params[:key])
    
    @requester = Character.find_by_id(request_data[:character_id])
    @mission = Mission.find(params[:id])

    @help_result = current_character.mission_help_results.create(:requester => @requester, :mission => @mission)
  end
  
  def collect_help_reward
    @basic_money, @experience = current_character.mission_helps.collect_reward!
    
    render :layout => 'ajax'
  end
  
  protected
  
  def fetch_missions
    current_character.mission_groups.current.missions.with_state(:visible).visible_for(current_character)
  end

  def mission_event_data(event_type, result)
    {
      :event_type => event_type,
      :character_id => result.character.id,
      :level => result.character.level,
      :reference_id => result.mission.id,
      :reference_type => "Mission",
      :basic_money => result.money,
      :experience => result.experience,
      :occurred_at => Time.now
    }.to_json
  end
end
