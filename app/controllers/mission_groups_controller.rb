class MissionGroupsController < ApplicationController
  def index
    show

    render :action => :show
  end

  def show
    @mission_group = current_character.mission_groups.current(params[:id])
    
    @missions = @mission_group.missions.with_state(:visible)
    @bosses = @mission_group.bosses.with_state(:visible)
  end
end
