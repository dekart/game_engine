module Payouts
  class VipMoney < Base
    def apply(character)
      character.vip_money += @value

      @action = :received
    end
  end
end