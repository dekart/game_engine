module Payouts
  class BasicMoney < Base
    def apply(character)
      character.basic_money += @value

      @action = :received
    end
  end
end