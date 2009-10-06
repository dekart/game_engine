class MissionsController < ApplicationController
  def index
    @current_mission_group = current_character.mission_groups.current(params[:mission_group_id])
    
    @mission_groups = current_character.mission_groups.current_page
    
    @missions = @current_mission_group.missions.available_for(current_character)
  end

  def fulfill
    @mission = Mission.find(params[:id])

    @result = MissionResult.create(current_character, @mission)

    unless @result.new_record?
      goal(@result.rank.just_completed? ? :mission_complete : :mission_fulfill, @mission.id)
    end

    render :action => :fulfill, :layout => "ajax"
  end
end
