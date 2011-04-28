module Requirements
  class HealthPoint < Base
    def satisfies?(character)
      character.hp >= @value
    end
    
    def to_s
      I18n.t('requirements.health_point.text', :amount => @value)
    end
  end
end
