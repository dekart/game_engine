module Payouts
  class StaminaPointsTotal < Base
    def apply(character, reward, reference)
      if action == :remove
        reward.decrease_attribute(:stamina, @value)
      else
        reward.increase_attribute(:stamina, @value)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:stamina] -= @value
      else
        reward.values[:stamina] += @value
      end
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("stamina"),
        chance,
        action
      ]
    end
  end
end
