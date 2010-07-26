module Payouts
  class BasicMoney < Base
    def value=(value)
      @value = value.to_i
    end
    
    def apply(character)
      if action == :remove
        character.charge(@value, 0)
      else
        character.charge(- @value, 0)
      end
    end
  end
end