class RatingsController < ApplicationController
  def show
    fetch_ratings(current_character)
  end

  def global
    fetch_ratings
    
    render :action => :show
  end
  
  protected
  
  def fetch_ratings(context = nil)
    @level       = Character.rated_by(:level, context)
    @total_money = Character.rated_by(:total_money, context)
    @fights      = Character.rated_by(:fights_won, context)
    @missions    = Character.rated_by(:missions_succeeded, context)
    @relations   = Character.rated_by(:relations_count, context)
    @monsters    = Character.rated_by(:killed_monsters_count, context)
  end
end
