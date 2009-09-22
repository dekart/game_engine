module Requirements
  class Defence < Base
    def initialize(value)
      @value = value.to_i
    end

    def satisfies?(character)
      character.own_defence_points >= @value
    end
  end
end