module Jobs
  class AchievementRegistration < Struct.new(:achievement_id)
    def perform
      if achievement = Achievement.find_by_id(achievement_id)
        achievement.register_in_facebook!
      end
    end
  end
end