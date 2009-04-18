module Effects
  class RestoreHealth < Base
    def apply(character)
      character.hp += self.value
    end
  end
end