module Payouts
  class DefencePointsTotal < Base
    def apply(character, reward, reference)
      if action == :remove
        reward.decrease_attribute(:defence, @value)
      else
        reward.increase_attribute(:defence, @value)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:defence] -= @value
      else
        reward.values[:defence] += @value
      end
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("defence"),
        chance,
        action
      ]
    end
  end
end
