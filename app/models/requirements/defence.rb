module Requirements
  class Defence < Base
    def initialize(value)
      @value = value.to_i
    end

    def satisfies?(character)
      character.defence >= @value
    end
  end
end