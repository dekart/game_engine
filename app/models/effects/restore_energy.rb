module Effects
  class RestoreEnergy < Base
    def apply(character)
      character.ep += self.value
    end
  end
end