module Payouts
  class BasicMoney < Base
    def value=(value)
      @value = value.to_i
    end
    
    def apply(character, reference = nil)
      if action == :remove
        character.charge(@value, 0, reference)
      else
        character.charge(- @value, 0, reference)
      end
    end
  end
end