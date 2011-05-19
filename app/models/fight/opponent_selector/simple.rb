class Fight
  module OpponentSelector
    module Simple
      def can_attack?
        (lowest_opponent_level .. highest_opponent_level).include?(victim.level)
      end
      
      def opponents
        Character.scoped(
          :conditions => ["level BETWEEN ? AND ?", lowest_opponent_level, highest_opponent_level]
        )
      end
      
      protected
      
      def lowest_opponent_level
        attacker.level - Setting.i(:fight_victim_levels_lower)
      end

      def highest_opponent_level
        attacker.level + Setting.i(:fight_victim_levels_higher)
      end
    end
  end
end