class RatingsController < ApplicationController
  def show
    fetch_ratings
    
    @total_score = Rating.new(:total_score)
  end
  
  protected
  
  def fetch_ratings(context = nil)
    @total_score = Character.rated_by(:total_score, context)
    @level       = Character.rated_by(:level, context)
    @total_money = Character.rated_by(:total_money, context)
    @fights      = Character.rated_by(:fights_won, context)
    @missions    = Character.rated_by(:missions_succeeded, context)
    @relations   = Character.rated_by(:relations_count, context)
    @monsters    = Character.rated_by(:killed_monsters_count, context)
  end
end
