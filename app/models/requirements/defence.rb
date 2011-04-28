module Requirements
  class Defence < Base
    def satisfies?(character)
      character.defence >= @value
    end
    
    def to_s
      I18n.t('requirements.defence.text', :amount => @value)
    end
  end
end
