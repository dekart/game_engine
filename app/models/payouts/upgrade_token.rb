module Payouts
  class UpgradeToken < Base
    def apply(character, reference = nil)
      if action == :remove
        character.upgrade_tokens -= @value
        character.upgrade_tokens = 0 if character.upgrade_tokens < 0
      else
        character.upgrade_tokens += @value
      end
    end
    
    def to_s
      "%s: %d %s (%d%% %s)" % [
        apply_on_label,
        value,
        Character.human_attribute_name("upgrade_tokens"),
        chance,
        action
      ]
    end
  end
end
