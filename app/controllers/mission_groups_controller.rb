class MissionGroupsController < ApplicationController
  def index
    show

    render :action => :show
  end

  def show
    @mission_group = current_character.mission_groups.current(params[:id])
  end
end
