module Payouts
  class Experience < Base
    def apply(character, reward, reference)
      reward.give_experience(@value)
    end

    def preview(reward)
      reward.values[:experience] += @value
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("experience"),
        chance,
        action
      ]
    end
  end
end
