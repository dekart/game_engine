class AchievementsController < ApplicationController
  skip_authentication_filters :only => :show
  skip_before_filter :check_standalone

  # This action is used to provide an information about achievement to Facebook. There is no reason to
  def show
    @achievement_type = AchievementType.with_state(:visible).find(params[:id])
  end

  def index
    @achievement_types = AchievementType.with_state(:visible)
  end

  def update
    @achievement = current_character.achievements.find(params[:id])

    @result = @achievement.collect!
  end
end
