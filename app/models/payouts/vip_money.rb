module Payouts
  class VipMoney < Base
    def apply(character, reference = nil)
      if action == :remove
        character.charge(0, @value, reference)
      else
        character.charge(0, - @value, reference)
      end
    end
    
    def to_s
      "%s: %s %s (%d%% %s)" % [
          apply_on_label,
          value,
          Character.human_attribute_name("vip_money"),
          chance,
          action
        ]
    end
  end
end
