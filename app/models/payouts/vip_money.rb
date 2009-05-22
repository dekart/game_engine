module Payouts
  class VipMoney < Base
    def apply(character)
      character.vip_money += @value

      return self
    end
  end
end