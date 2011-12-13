module Payouts
  class EnergyPoint < Base
    include RecoveryMode
    
    def apply(character, reference = nil)
      @calculated_value = calculate_value(character.energy)
      
      if action == :remove
        character.ep -= @calculated_value
      else
        character.ep += @calculated_value
      end
    end
    
    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("ep"),
        chance,
        action
      ]
    end
  end
end
