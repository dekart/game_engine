module GameData
  class Item < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/items/**/*.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    PICTURE_FORMATS = %w{icon small stream medium large}

    attr_accessor :level, :placements, :basic_price, :vip_price, :package_size, :sell_price, :max_market_price, :boost, :effects

    def initialize(key)
      super

      @placements = []
      @effects = {}
    end

    def group=(value)
      @group_id = value
    end

    def group
      GameData::ItemGroup[@group_id]
    end

    def level
      @level || 1
    end

    def package_size
      @package_size || 1
    end

    def name
      I18n.t("data.items.#{ @key }.name")
    end

    def description
      I18n.t("data.items.#{ @key }.description", :default => '')
    end

    def in_shop_for?(character)
      tags.include?(:shop) and
      character.level >= level
    end

    def in_shop_and_locked_for?(character)
      tags.include?(:shop) and
      level > character.level
    end

    def special_for?(character)
      tags.include?(:special) and
      character.level >= level
    end

    def as_json(*options)
      super.merge!(
        :name => name,
        :description => description,
        :level => level,
        :pictures => pictures,
        :purchaseable => tags.include?(:shop),
        :package_size => package_size,
        :basic_price => basic_price,
        :vip_price => vip_price,
        :effects => effects,
      ).tap{|r|
        r.reject!{|k, v| v.blank? }
      }
    end

    def as_json_for(character)
      as_json.merge!(
        :reward_on_use => preview_reward_on(:use, character)
      )
    end
  end
end