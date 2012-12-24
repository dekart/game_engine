module Payouts
  class HealthPoint < Base
    include RecoveryMode

    def apply(character, reward, reference)
      @calculated_value = calculate_value(character.health)

      if action == :remove
        reward.take_health(@calculated_value)
      else
        reward.give_health(@calculated_value, can_exceed_maximum)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:hp] -= @value
      else
        reward.values[:hp] += @value
      end
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("hp"),
        chance,
        action
      ]
    end
  end
end
