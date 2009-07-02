module Payouts
  class VipMoney < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      character.vip_money += @value
    end
  end
end