module Requirements
  class Level < Base
    def satisfies?(character)
      character.level >= @value
    end
    
    def to_s
      I18n.t('requirements.level.text', :required_value => @value)
    end
  end
end
