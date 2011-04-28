module Requirements
  class Alliance < Base
    def satisfies?(character)
      character.relations.effective_size >= @value
    end
    
    def to_s
      I18n.t('requirements.alliance.text', :amount => @value)
    end
  end
end
