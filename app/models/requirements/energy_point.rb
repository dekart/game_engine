module Requirements
  class EnergyPoint < Base
    def satisfies?(character)
      character.ep >= @value
    end
    
    def to_s
      I18n.t('requirements.energy_point.text', :amount => @value)
    end
  end
end
