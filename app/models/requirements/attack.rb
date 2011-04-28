module Requirements
  class Attack < Base
    def satisfies?(character)
      character.attack >= @value
    end
    
    def to_s
      I18n.t('requirements.attack.text', :amount => @value)
    end
  end
end
