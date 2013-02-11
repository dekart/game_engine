module GameData
  class ItemGroup < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/item_groups.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    def items
      @items ||= GameData::Item.select{|m| m.group == self }
    end

    def name
      I18n.t("data.item_groups.#{ @key }")
    end

    def as_json(*options)
      super.merge!(
        :name => name
      ).tap{|r|
        r.reject!{|k, v| v.blank? }
      }
    end
  end
end