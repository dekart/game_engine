module Payouts
  class HealthPoint < Base
    def apply(character, reference = nil)
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
