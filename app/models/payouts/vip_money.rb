module Payouts
  class VipMoney < Base
    def apply(character, reward, reference)
      if action == :remove
        reward.take_vip_money(@value)
      else
        reward.give_vip_money(@value)
      end
    end

    def preview(reward)
      if action == :remove
        reward.values[:vip_money] -= @value
      else
        reward.values[:vip_money] += @value
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
