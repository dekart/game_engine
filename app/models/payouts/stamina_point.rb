module Payouts
  class StaminaPoint < Base
    include RecoveryMode

    attr_accessor :can_exceed_maximum

    def apply(character, reward, reference)
      @calculated_value = calculate_value(character.stamina)

      if action == :remove
        reward.take_stamina(@calculated_value)
      else
        reward.give_stamina(@calculated_value, can_exceed_maximum)
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
