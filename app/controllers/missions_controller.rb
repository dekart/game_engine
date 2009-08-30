class MissionsController < ApplicationController
  def index
    @missions = Mission.available_for(current_character)
  end

  def fulfill
    @mission = Mission.find(params[:id])

    @result = MissionResult.create(current_character, @mission)

    unless @result.new_record?
      goal(@result.completed? ? :mission_complete : :mission_fulfill, @mission.id)
    end

    render :action => :fulfill, :layout => "ajax"
  end
end
