class MissionGroupsController < ApplicationController
  def index
    show
  end

  def show
    if @mission_group = current_character.mission_groups.current(params[:id])
      @missions = current_character.missions.by_group(@mission_group)
      @bosses = @mission_group.bosses.with_state(:visible).visible_for(current_character)
    else
      @missions = []
      @bosses = []
    end

    respond_to do |format|
      format.html {render :action => :show}
      format.js { render :action => :show, :layout => false }
    end
  end
end
