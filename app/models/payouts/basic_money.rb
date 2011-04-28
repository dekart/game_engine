module Payouts
  class BasicMoney < Base
    def apply(character, reference = nil)
      if action == :remove
        character.charge(@value, 0, reference)
      else
        character.charge(- @value, 0, reference)
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
