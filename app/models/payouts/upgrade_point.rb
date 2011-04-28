module Payouts
  class UpgradePoint < Base
    def apply(character, reference = nil)
      if action == :remove
        character.points -= @value
        character.points = 0 if character.points < 0
      else
        character.points += @value
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
