module Payouts
  class StaminaPoint < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      if action == :remove
        character.sp -= @value
      else
        character.sp += @value
      end
    end
  end
end