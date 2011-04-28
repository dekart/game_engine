module Payouts
  class StaminaPoint < Base
    def apply(character, reference = nil)
      if action == :remove
        character.sp -= @value
      else
        character.sp += @value
      end
    end
    
    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("sp"),
        chance,
        action
      ]
    end
  end
end
