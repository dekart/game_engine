module Payouts
  class EnergyPoint < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      if action == :remove
        character.ep -= @value
      else
        character.ep += @value
      end
    end
  end
end