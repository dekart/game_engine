module Payouts
  class VipMoney < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      if action == :remove
        character.charge(0, @value)
      else
        character.charge(0, - @value)
      end
    end
  end
end