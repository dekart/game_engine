module Payouts
  class StaminaPoint < Base
    include RecoveryMode
    
    def apply(character, reference = nil)
      @recalc_value = recalc_recovery(character.stamina)
      
      if action == :remove
        character.sp -= @recalc_value
      else
        character.sp += @recalc_value
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
