module Payouts
  class DefencePointsTotal < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character, reference = nil)
      if action == :remove
        character.defence -= @value
      else
        character.defence += @value
      end
    end
  end
end
