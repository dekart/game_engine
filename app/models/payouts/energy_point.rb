module Payouts
  class EnergyPoint < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character, reference = nil)
      if action == :remove
        character.ep -= @value
      else
        character.ep += @value
      end
    end
  end
end