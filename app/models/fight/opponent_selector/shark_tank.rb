class Fight
  module OpponentSelector
    module SharkTank
      LEVEL_RANGES = [
        1 .. 1, 
        2 .. 2, 
        3 .. 3, 
        4 .. 4, 
        5 .. 5, 
        6 .. 10, 
        11 .. 15, 
        16 .. 25, 
        26 .. 50, 
        51 .. 100, 
        101 .. Character::Levels::EXPERIENCE.size
      ]
      
      def can_attack?
        attacker_level_range.include?(victim.level)
      end
      
      def opponents
        Character.scoped(
          :conditions => ["level BETWEEN ? AND ?", attacker_level_range.begin, attacker_level_range.end]
        )
      end
      
      def attacker_level_range
        LEVEL_RANGES.detect{|r| r.include?(attacker.level) }
      end
    end
  end
end