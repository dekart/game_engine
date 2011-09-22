module Notification
  class NewAchievement < Base
    def achievement
      @achievement ||= character.achievements.find(data[:achievement_id])
    end
  end
end