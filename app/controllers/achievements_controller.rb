class AchievementsController < ApplicationController
  def index
    @achievement_types = AchievementType.with_state(:visible)
  end
  
  def update
    @achievement = current_character.achievements.find(params[:id])
    
    @result = @achievement.collect!
    
    render :layout => 'ajax'
  end
end
