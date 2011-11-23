module Payouts
  class StaminaPoint < Base
    include RecoveryMode
    
    def apply(character, reference = nil)
      @value = (recovery_mode == :absolute) ? @value : ((character.stamina / 100.0) * @value).ceil
      
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
