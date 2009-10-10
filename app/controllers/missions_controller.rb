class MissionsController < ApplicationController
  helper_method :tutorial?

  def index
    @current_mission_group = current_character.mission_groups.current(params[:mission_group_id])
    
    @mission_groups = current_character.mission_groups.current_page
    
    @missions = @current_mission_group.missions.available_for(current_character)
  end

  def fulfill
    @mission = Mission.find(params[:id])

    @result = MissionResult.create(current_character, @mission)

    if params[:tutorial]
      @missions = Mission.available_for(current_character).all(:limit => 1)
    else
      @missions = current_character.missions.available
      @mission_groups = current_character.mission_groups.current_page
    end

    render :action => :fulfill, :layout => "ajax"
  end

  protected

  def tutorial?
    params[:tutorial] == "true"
  end
end
