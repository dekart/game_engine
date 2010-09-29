module Payouts
  class StaminaPointsTotal < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character, reference = nil)
      if action == :remove
        character.stamina -= @value
      else
        character.stamina += @value
      end
    end
  end
end
