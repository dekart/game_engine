module Payouts
  class Mercenary < Base
    attr_reader :mercenaries

    def apply(character, reward, reference)
      if action == :remove
        reward.take_mercenaries(@value)
      else
        reward.give_mercenaries(@value)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:mercenaries] -= @value
      else
        reward.values[:mercenaries] += @value
      end
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("mercenaries"),
        chance,
        action
      ]
    end
  end
end
