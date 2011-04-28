module Payouts
  class EnergyPoint < Base
    def apply(character, reference = nil)
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
