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
      Data::ItemGroup.groups[@group_id]
    end

    def level
      @level || 1
    end

    def name
      I18n.t("data.items.#{@key}.name")
    end

    def description
      I18n.t("data.missions.#{@key}.description", :default => '')
    end

    def as_json(*options)
      super.merge!(
        :name => name,
        :description => description,
        :pictures => pictures,
        :tags => tags,
        :level => level
      ).reject!{|k, v| v.blank? }
    end
  end
end