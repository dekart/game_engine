class MissionsController < ApplicationController
  def index
    @missions = Mission.available_for(current_character)
  end

  def fulfill
    @mission = Mission.find(params[:id])

    @result = MissionResult.create(current_character, @mission)

    render :action => :fulfill, :layout => "ajax"
  end
end
