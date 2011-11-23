module Payouts
  class HealthPoint < Base
    include RecoveryMode
    
    def apply(character, reference = nil)
      @calculated_value = calculate_value(character.health)
      
      if action == :remove
        character.hp -= @calculated_value
      else
        character.hp += @calculated_value
      end
    end
    
    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("hp"),
        chance,
        action
      ]
    end
  end
end
