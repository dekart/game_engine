module Requirements
  class Attack < Base
    def satisfies?(character)
      character.own_attack_points >= @value
    end
  end
end