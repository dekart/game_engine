class MissionsController < ApplicationController
  def fulfill
    @mission = Mission.find(params[:id])

    @result = current_character.missions.fulfill!(@mission)

    if @result.level_rank.just_completed?
      @missions = current_character.mission_groups.current.missions.with_state(:visible).visible_for(current_character)
    end

    render :fulfill, :layout => "ajax"
  end
end
