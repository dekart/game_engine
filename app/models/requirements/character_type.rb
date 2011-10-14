module Requirements
  class CharacterType < Base
    def value=(value)
      @value = value.is_a?(::CharacterType) ? value.id : value.to_i
    end

    def character_type
      @item ||= ::CharacterType.find_by_id(value)
    end

    def satisfies?(character)
      character.character_type == character_type
    end

    def to_s
      I18n.t('requirements.character_type.text', 
        :name => character_type.try(:name)
      )
    end
  end
end
