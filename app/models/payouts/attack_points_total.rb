module Payouts
  class AttackPointsTotal < Base
    def apply(character, reward, reference)
      if action == :remove
        reward.decrease_attribute(:attack, @value)
      else
        reward.increase_attribute(:attack, @value)
      end
    end

    def to_s
      '%s: %d %s (%d%% %s)' % [
        apply_on_label,
        value,
        Character.human_attribute_name("attack"),
        chance,
        action
      ]
    end
  end
end
