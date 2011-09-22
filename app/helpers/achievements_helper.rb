module AchievementsHelper
  def achievement_list(types)
    achievements = current_character.achievements.all
    
    types.each do |type|
      yield(type, achievements.detect{|a| a.achievement_type_id == type.id })
    end
  end
end
