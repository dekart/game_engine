module I18n
  module Backend
    class YamlDb < Simple
      protected

      def init_translations
        super

        return unless Translation.table_exists?

        available_locales.each do |locale|
          store_translations(locale, Translation.to_hash)
        end
      end
    end
  end
end
