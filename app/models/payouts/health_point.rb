module Payouts
  class HealthPoint < Base
    include RecoveryMode
    
    def apply(character, reference = nil)
      @value = (recovery_mode == :absolute) ? @value : ((character.health / 100.0) * @value).ceil
      
      if action == :remove
        character.hp -= @value
      else
        character.hp += @value
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
