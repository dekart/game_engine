module Payouts
  class EnergyPoint < Base
    include RecoveryMode

    def apply(character, reward, reference)
      @calculated_value = calculate_value(character.energy)

      if action == :remove
        reward.take_energy(@calculated_value)
      else
        reward.give_energy(@calculated_value, can_exceed_maximum)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:ep] -= @value
      else
        reward.values[:ep] += @value
      end
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("ep"),
        chance,
        action
      ]
    end
  end
end
