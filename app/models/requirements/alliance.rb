module Requirements
  class Alliance < Base
    def satisfies?(character)
      character.relations.size >= @value
    end
  end
end