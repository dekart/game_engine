class MissionsController < ApplicationController
  def index
    @current_mission_group = current_character.mission_groups.current(params[:mission_group_id])
    
    @mission_groups = current_character.mission_groups.current_page
    
    @missions = @current_mission_group.missions
  end

  def fulfill
    @mission = Mission.find(params[:id])

    @result = MissionResult.create(current_character, @mission)

    if @result.rank.just_completed?
      @missions = current_character.mission_groups.current.missions
    end

    @mission_groups = current_character.mission_groups.current_page

    render :action => :fulfill, :layout => "ajax"
  end
end
