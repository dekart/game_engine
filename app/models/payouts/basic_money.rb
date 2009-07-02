module Payouts
  class BasicMoney < Base
    def value=(value)
      @value = value.to_i
    end
    
    def apply(character)
      character.basic_money += @value
    end
  end
end