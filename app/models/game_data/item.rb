module GameData
  class Item < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/items/**/*.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

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
  end
end