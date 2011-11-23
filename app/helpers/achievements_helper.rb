module AchievementsHelper
  def achievement_list(types)
    achievements = current_character.achievements.all
    
    types_uncollected = [].tap do |result|
      achievements.each do |a|
        unless a.collected?
          types.reject! do |type|
            if a.achievement_type_id == type.id
              result << type 
            end
          end
        end
      end
    end

    types.unshift(*types_uncollected)
   
    types.each do |type|
      yield(type, achievements.detect{|a| a.achievement_type_id == type.id })
    end
  end
end
