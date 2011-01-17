class Character
  module Levels
    def self.included(base)
      base.extend(ClassMethods)
    end
        
    module ClassMethods
      def level_for_experience(value)
        EXPERIENCE.each_with_index do |experience, level|
          return level if experience >= value
        end
      end
    end

    EXPERIENCE = [0]

    1000.times do |i|
      EXPERIENCE[i + 1] = ((EXPERIENCE[i].to_i * 1.02 + (i + 1) * 10).round / 10.0).round * 10
    end
    
    def experience_to_next_level
      next_level_experience - experience
    end

    def next_level_experience
      EXPERIENCE[level]
    end

    def level_progress_percentage
      (100 - experience_to_next_level.to_f / (next_level_experience - EXPERIENCE[level - 1]) * 100).round
    end
    
  end
end