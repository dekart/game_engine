class Character
  module Achievements
    def self.included(base)
      base.class_eval do
        has_many :achievements,
          :include => :achievement_type,
          :extend => AchievementsExtension

        after_update :check_achievement_reach
      end
    end
    
    module AchievementsExtension
      def cache_key
        "character_#{ proxy_association.owner.id }_achievements"
      end
      
      def clear_achievements_cache!
        Rails.cache.delete(cache_key)

        true
      end

      def achieved_ids
        @achieved_ids ||= Rails.cache.fetch(cache_key, :expires_in => 15.minutes) do
          find_by_sql(
            Achievement.send(:sanitize_sql, ['SELECT achievement_type_id FROM achievements WHERE character_id = ?', proxy_association.owner.id])
          ).map{|a| a.achievement_type_id }
        end
      end
      
      def value(type)
        proxy_association.owner.send(type.key)
      end
      
      def progress(type)
        (value(type).to_f / type.value * 100).ceil
      end
      
      def achieved?(type)
        achieved_ids.include?(type.id)
      end
      
      def in_progress?(type)
        !achieved?(type) && AchievementType.index[type.key].detect{|goal, id| goal > value(type) }.try(:last) == type.id
      end
      
      def achieve!(types)
        types = Array.wrap(types)

        unless types.empty?
          types.each do |type|
            create!(:character => proxy_association.owner, :achievement_type => type)
          end

          clear_achievements_cache!
        end
      end
    end
    
    def check_achievement_reach
      achievement_ids = []
      
      AchievementType::KEYS.each do |key|
        if changes[key.to_s] && AchievementType.index[key]
          current_value = changes[key.to_s][1]
          
          achievement_ids.push(*AchievementType.index[key].collect{|value, id| id if value <= current_value })
        end
      end
      
      achievement_ids.compact!
      achievement_ids -= achievements.achieved_ids
      
      achievements.achieve!(AchievementType.find(achievement_ids))

      true
    end
  end
end