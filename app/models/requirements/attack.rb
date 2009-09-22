module Requirements
  class Attack < Base
    def initialize(value)
      @value = value.to_i
    end

    def satisfies?(character)
      character.own_attack_points >= @value
    end
  end
end