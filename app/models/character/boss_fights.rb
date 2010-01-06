class Character
  module BossFights
    def find_by_boss(boss)
      find_by_boss_id_and_workflow_state(boss.id, "progress") || build_by_boss(boss)
    end

    def build_by_boss(boss)
      returning fight = build(:boss => boss) do
        fight.expire_at = Time.now + boss.time_limit.to_i.hours
        fight.health    = boss.health
      end
    end
  end
end