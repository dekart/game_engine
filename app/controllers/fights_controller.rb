class FightsController < ApplicationController
  def new
    @victims = Character.victims_for(current_character).find(:all, :order => "RAND()", :limit => 10)
  end

  def create
    if @victim = Character.victims_for(current_character).find(:first, :conditions => {:id => params[:victim_id]})
      @fight = current_character.attacks.create(:victim => @victim)
    end
    
    render :action => :create, :layout => "ajax"
  end
end
