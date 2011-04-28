module Payouts
  class Experience < Base
    def apply(character, reference = nil)
      character.experience += @value
    end
    
    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("experience"),
        chance,
        action
      ]
    end
  end
end
