module Dice
  class << self
    def chance(value, base = 100)
      rand(base) < value
    end
  end
end