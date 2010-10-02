module Payouts
  class HealthPointsTotal < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character, reference = nil)
      if action == :remove
        character.health -= @value
      else
        character.health += @value
      end
    end
  end
end
