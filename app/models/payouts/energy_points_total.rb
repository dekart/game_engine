module Payouts
  class EnergyPointsTotal < Base
    def apply(character, reward, reference)
      if action == :remove
        reward.decrease_attribute(:energy, @value)
      else
        reward.increase_attribute(:energy, @value)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:energy] -= @value
      else
        reward.values[:energy] += @value
      end
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("energy"),
        chance,
        action
      ]
    end
  end
end
