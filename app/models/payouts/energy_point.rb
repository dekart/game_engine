module Payouts
  class EnergyPoint < Base
    include RecoveryMode

    attr_accessor :can_exceed_maximum

    def apply(character, reward, reference)
      @calculated_value = calculate_value(character.energy)

      if action == :remove
        reward.take_energy(@calculated_value)
      else
        reward.give_energy(@calculated_value, can_exceed_maximum)
      end
    end

    def can_exceed_maximum=(value)
      if value == true || value == false
        @can_exceed_maximum = value
      else
        @can_exceed_maximum = (value.to_i != 0)
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
