class MissionsController < ApplicationController
  def index
    @missions = Mission.available_for(current_character)
  end

  def fulfill
    @mission = Mission.find(params[:id])

    @success = current_character.fulfill_mission!(@mission)

    render :action => :fulfill, :layout => false
  end
end
