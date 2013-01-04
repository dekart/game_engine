module GameData
  class CharacterType < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/character_types/*.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    PICTURE_FORMATS = %w{small}

    attr_accessor :attributes

    def name
      I18n.t("data.character_types.#{@key}.name")
    end

    def description
      I18n.t("data.character_types.#{@key}.name")
    end
  end
end