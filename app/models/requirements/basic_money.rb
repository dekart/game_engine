module Requirements
  class BasicMoney < Base
    def satisfies?(character)
      character.basic_money >= @value
    end
    
    def to_s
      I18n.t('requirements.basic_money.text', :amount => @value)
    end
  end
end
