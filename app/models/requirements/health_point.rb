module Requirements
  class HealthPoint < Base
    def initialize(value)
      @value = value.to_i
    end

    def satisfies?(character)
      character.hp >= @value
    end
  end
end