module Payouts
  class UpgradePoint < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      if action == :remove
        character.points -= @value
        character.points = 0 if character.points < 0
      else
        character.points += @value
      end
    end
  end
end