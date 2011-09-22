module Jobs
  class AchievementTypeRegistration < Struct.new(:achievement_type_id)
    def perform
      if type = AchievementType.find_by_id(achievement_type_id)
        type.register_in_facebook!
      end
    end
  end
end