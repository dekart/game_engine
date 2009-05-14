module Effects
  class IncreasePoints < Base
    def apply(character)
      character.points += self.value
    end
  end
end