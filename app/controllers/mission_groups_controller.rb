class MissionGroupsController < ApplicationController
  def index
    show
  end

  def show
    if @mission_group = current_character.mission_groups.current(params[:id])
      @missions = @mission_group.missions.available_for(current_character)
    else
      @missions = []
    end

    respond_to do |format|
      format.html {render :action => :show}
      format.js { render :action => :show, :layout => false }
    end
  end
end
