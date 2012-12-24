module Payouts
  class HealthPointsTotal < Base
    def apply(character, reward, reference)
      if action == :remove
        reward.decrease_attribute(:health, @value)
      else
        reward.increase_attribute(:health, @value)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:health] -= @value
      else
        reward.values[:health] += @value
      end
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("health"),
        chance,
        action
      ]
    end
  end
end
