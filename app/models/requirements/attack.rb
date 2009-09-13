module Requirements
  class Attack < Base
    def initialize(value)
      @value = value.to_i
    end

    def satisfies?(character)
      character.attack >= @value
    end
  end
end