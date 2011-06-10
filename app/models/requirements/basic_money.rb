module Requirements
  class BasicMoney < Base
    def satisfies?(character)
      character.basic_money >= @value
    end
    
    def to_s
      I18n.t('requirements.basic_money.text', :required_value => @value)
    end
  end
end
