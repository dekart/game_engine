class RatingsController < ApplicationController
  def show
    @rating_scope ||= current_character.self_and_relations
    
    @level       = @rating_scope.rated_by(:level)
    @bank        = @rating_scope.rated_by(:bank)
    @fights      = @rating_scope.rated_by(:fights_won)
    @missions    = @rating_scope.rated_by(:missions_succeeded)
    @relations   = @rating_scope.rated_by(:relations_count)

    render :action => :show
  end

  def global
    @rating_scope = Character

    show
  end
end
