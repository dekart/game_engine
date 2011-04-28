module Payouts
  class EnergyPointsTotal < Base
    def apply(character, reference = nil)
      if action == :remove
        character.energy -= @value
      else
        character.energy += @value
      end
    end
    
    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("energy"),
        chance,
        action
      ]
    end
  end
end
