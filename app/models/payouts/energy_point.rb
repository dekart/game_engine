module Payouts
  class EnergyPoint < Base
    include RecoveryMode
    
    def apply(character, reference = nil)
      @value = (recovery_mode == :absolute) ? @value : ((character.energy / 100.0) * @value).ceil
      
      if action == :remove
        character.ep -= @value
      else
        character.ep += @value
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
