module Payouts
  class StaminaPoint < Base
    include RecoveryMode
    
    def apply(character, reference = nil)
      @calculated_value = calculate_value(character.stamina)
      
      if action == :remove
        character.sp -= @calculated_value
      else
        character.sp += @calculated_value
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
