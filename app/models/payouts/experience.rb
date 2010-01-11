module Payouts
  class Experience < Base
    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      character.experience += @value
    end
  end
end