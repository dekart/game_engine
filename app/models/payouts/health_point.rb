module Payouts
  class HealthPoint < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      if action == :remove
        character.hp -= @value
      else
        character.hp += @value
      end
    end
  end
end