module Payouts
  class BasicMoney < Base
    def apply(character, reward, reference)
      if action == :remove
        reward.take_basic_money(@value)
      else
        reward.give_basic_money(@value)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:basic_money] -= @value
      else
        reward.values[:basic_money] += @value
      end
    end

    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("basic_money"),
        chance,
        action
      ]
    end
  end
end
