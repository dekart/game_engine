module Requirements
  class Defence < Base
    def satisfies?(character)
      character.own_defence_points >= @value
    end
  end
end