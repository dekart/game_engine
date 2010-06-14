module Payouts
  class VipMoney < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      if action == :remove
        character.vip_money -= @value
      else
        character.vip_money += @value
      end
    end
  end
end