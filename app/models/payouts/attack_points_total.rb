module Payouts
  class AttackPointsTotal < Base
    def apply(character, reference = nil)
      if action == :remove
        character.attack -= @value
      else
        character.attack += @value
      end
    end
    
    def to_s
      '%s: %d %s (%d%% %s)' % [
        apply_on_label,
        value,
        Character.human_attribute_name("attack"),
        chance,
        action
      ]
    end
  end
end
