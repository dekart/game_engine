module Effects
  class Upgrade < Base
    def apply(character)
      character.points += self.value
    end
  end
end