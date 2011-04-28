module Payouts
  class DefencePointsTotal < Base
    def apply(character, reference = nil)
      if action == :remove
        character.defence -= @value
      else
        character.defence += @value
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
