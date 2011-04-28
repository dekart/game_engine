module Payouts
  class HealthPointsTotal < Base
    def apply(character, reference = nil)
      if action == :remove
        character.health -= @value
      else
        character.health += @value
      end
    end
    
    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("health"),
        chance,
        action
      ]
    end
  end
end
