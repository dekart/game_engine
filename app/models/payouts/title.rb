module Payouts
  class Title < Base
    delegate :state, :to => :title
    
    def value=(value)
      @value = value.is_a?(::Title) ? value.id : value.to_i
    end

    def title
      @title ||= ::Title.find_by_id(value)
    end

    def apply(character, reference = nil)
      if action == :remove
        character.titles.delete(title)
      else
        character.titles << title unless character.titles.include?(title)
      end
    end
    
    def to_s
      "%s: '%s' %s (%d%% %s)" % [
        apply_on_label,
        title.name,
        ::Title.human_name,
        chance,
        action
      ]
    end
  end
end
