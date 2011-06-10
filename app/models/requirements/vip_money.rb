module Requirements
  class VipMoney < Base
    def satisfies?(character)
      character.vip_money >= @value
    end
    
    def to_s
      I18n.t('requirements.vip_money.text', :required_value => @value)
    end
  end
end