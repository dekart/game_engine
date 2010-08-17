module Payouts
  class VipMoney < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character, reference = nil)
      if action == :remove
        character.charge(0, @value, reference)
      else
        character.charge(0, - @value, reference)
      end
    end
  end
end