module Payouts
  class StaminaPoint < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      if self.action == :remove
        character.ep -= @value
      else
        character.ep += @value
      end
    end
  end
end