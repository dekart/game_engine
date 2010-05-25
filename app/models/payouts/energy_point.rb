module Payouts
  class EnergyPoint < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      if self.action == :remove
        character.sp -= @value
      else
        character.sp += @value
      end
    end
  end
end