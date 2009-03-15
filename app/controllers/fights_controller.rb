class FightsController < ApplicationController
  def new
    @victims = Character.victims_for(current_character)
  end

  def create
    @fight = current_character.attacks.create(:victim_id => params[:victim_id])

    render :action => :create, :layout => false
  end
end
