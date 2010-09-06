module Payouts
  class Title < Base
    def value=(value)
      @value = value.is_a?(::Title) ? value.id : value.to_i
    end

    def title
      ::Title.find_by_id(value)
    end

    def apply(character, reference = nil)
      if action == :remove
        character.titles << title
      else
        character.titles.delete(title)
      end
    end
  end
end