module Payouts
  class EnergyPointsTotal < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character, reference = nil)
      if action == :remove
        character.energy -= @value
      else
        character.energy += @value
      end
    end
  end
end
