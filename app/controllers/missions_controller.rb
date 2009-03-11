class MissionsController < ApplicationController
  def index
    @missions = Mission.available_for(current_character)
  end

  def fulfill
    @mission = Mission.find(params[:id])

    current_character.fulfill_mission!(@mission)

    redirect_to missions_path
  end
end
