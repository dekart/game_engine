module Payouts
  class StaminaPoint < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character, reference = nil)
      if action == :remove
        character.sp -= @value
      else
        character.sp += @value
      end
    end
  end
end