class MissionGroupsController < ApplicationController
  def index
    show
  end

  def show
    @mission_group = current_character.mission_groups.current(params[:id])
    
    @missions = @mission_group.missions.with_state(:visible).visible_for(current_character)
    @bosses = @mission_group.bosses.with_state(:visible).visible_for(current_character)

    respond_to do |format|
      format.html {render :action => :show}
      format.js { render :action => :show, :layout => false }
    end
  end
end
