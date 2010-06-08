class MissionsController < ApplicationController
  def fulfill
    @mission = Mission.find(params[:id])

    @result = MissionResult.create(current_character, @mission)

    if @result.rank.just_completed?
      @missions = current_character.mission_groups.current.missions.with_state(:visible).available_for(current_character)
    end

    @mission_groups = current_character.mission_groups.current_page

    render :action => :fulfill, :layout => "ajax"
  end
end
