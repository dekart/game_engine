module Requirements
  class StaminaPoint < Base
    def satisfies?(character)
      character.sp >= @value
    end
    
    def to_s
      I18n.t('requirements.stamina_point.text', :amount => @value)
    end
  end
end
