class Character
  module BossFights
    def won?(boss)
      won_boss_ids.include?(boss.id)
    end

    def won_boss_ids
      with_state(:won).all(:select => "DISTINCT boss_id").collect{|f| f.boss_id }
    end

    def find_by_boss(boss)
      with_state(:progress).find_by_boss_id(boss.id) || build_by_boss(boss)
    end

    def build_by_boss(boss)
      returning fight = build(:boss => boss) do
        fight.expire_at = Time.now + boss.time_limit.to_i.minutes if boss.time_limit?
        fight.health    = boss.health
      end
    end
  end
end