module Requirements
  class Title < Base
    def title
      ::Title.find_by_id(value)
    end

    def satisfies?(character)
      character.titles.find_by_id(value)
    end
  end
end