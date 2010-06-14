module Payouts
  class BasicMoney < Base
    def value=(value)
      @value = value.to_i
    end
    
    def apply(character)
      if action == :remove
        character.basic_money -= @value
      else
        character.basic_money += @value
      end
    end
  end
end