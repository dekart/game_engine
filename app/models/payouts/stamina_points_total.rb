module Payouts
  class StaminaPointsTotal < Base
    def apply(character, reference = nil)
      if action == :remove
        character.stamina -= @value
      else
        character.stamina += @value
      end
    end
    
    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("stamina"),
        chance,
        action
      ]
    end
  end
end
