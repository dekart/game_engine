class MissionsController < ApplicationController
  def index
    @missions = Mission.available_for(current_character)
  end

  def fulfill
    @mission = Mission.find(params[:id])

    if current_character.fulfill_mission!(@mission)
      render :action => :fulfill_success, :layout => false
    else
      render :action => :fulfill_fail, :layout => false
    end
  end
end
