module Payouts
  class UpgradePoint < Base
    def apply(character, reward, reference)
      if action == :remove
        reward.take_upgrade_points(@value)
      else
        reward.give_upgrade_points(@value)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:points] -= @value
      else
        reward.values[:points] += @value
      end
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("points"),
        chance,
        action
      ]
    end
  end
end
