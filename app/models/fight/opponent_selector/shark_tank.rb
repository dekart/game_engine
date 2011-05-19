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
      
      def can_attack?(victim)
        level_fits        = attacker_tank.include?(victim.level)
        attacked_recently = latest_opponent_ids.include?(victim.id)
        friendly_attack   = Setting.b(:fight_alliance_attack) ? false : attacker.friend_relations.character_ids.include?(victim.id)
        weak_opponent     = Setting.b(:fight_weak_opponents) ? false : victim.weak?

        level_fits && !attacked_recently && !friendly_attack && !weak_opponent
      end
      
      def opponents
        scope = Character.scoped(
          :conditions => ["level BETWEEN ? AND ?", lowest_opponent_level, highest_opponent_level]
        )

        # Exclude recent opponents, friends, and self
        exclude_ids = latest_opponent_ids
        exclude_ids.push(*attacker.friend_relations.character_ids) unless Setting.b(:fight_alliance_attack)
        exclude_ids.push(attacker.id)

        scope = scope.scoped(
          :conditions => ["characters.id NOT IN (?)", exclude_ids]
        )


        unless Setting.b(:fight_weak_opponents)
          scope = scope.scoped(
            :conditions => ["fighting_available_at < ?", Time.now.utc]
          )
        end

        scope.all(
          :include  => :user,
          :order    => "ABS(level - #{ attacker.level }) ASC, RAND()",
          :limit    => Setting.i(:fight_victim_show_limit)
        ).tap do |result|
          result.shuffle!
        end
      end
      
      protected
      
      def lowest_opponent_level
        attacker.level - Setting.i(:fight_victim_levels_lower)
      end

      def highest_opponent_level
        attacker.level + Setting.i(:fight_victim_levels_higher)
      end

      def latest_opponent_ids
        attacker.attacks.all(
          :select     => "DISTINCT victim_id",
          :conditions => ["winner_id = ? AND created_at > ?", attacker.id, Setting.i(:fight_attack_repeat_delay).minutes.ago]
        ).collect{|a| a.victim_id }
      end
    end
  end
end