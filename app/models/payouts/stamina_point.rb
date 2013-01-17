module Payouts
  class StaminaPoint < Base
    include RecoveryMode

    def apply(character, reward, reference)
      @calculated_value = calculate_value(character.stamina)

      if action == :remove
        reward.take_stamina(@calculated_value)
      else
        reward.give_stamina(@calculated_value, can_exceed_maximum)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:sp] -= @value
      else
        reward.values[:sp] += @value
      end
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("sp"),
        chance,
        action
      ]
    end
  end
end
