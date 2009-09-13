module Requirements
  class Alliance < Base
    def initialize(value)
      @value = value.to_i
    end

    def satisfies?(character)
      character.relations.size >= @value
    end
  end
end