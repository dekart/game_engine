module GameData
  class Item
    class << self
      def items
        @@items ||= {}

        if @@items.empty?
          # Load available encounters
          Dir[Rails.root.join('db/data/items/**/*.rb')].each do |file|
            eval File.read(file)
          end
        end

        @@items
      end

      def define(key, &block)
        @@items[key] = new(key).tap(&block)
      end
    end

    attr_reader :key
    attr_accessor :tags, :min_level, :placements, :basic_price, :vip_price, :package_size, :sell_price, :max_market_price, :boost, :effects

    def initialize(key)
      @key = key
      @tags = []
      @placements = []
      @effects = {}
      @rewards = {}
      @reward_previews = {}
    end

    def group=(value)
      @group_id = value
    end

    def group
      Data::ItemGroup.groups[@group_id]
    end

    def reward_on(key, &block)
      @rewards[key] = block
    end

    def reward_preview_on(key, &block)
      @reward_previews[key] = block
    end

    def apply_reward_on(key, character)
      Reward.new(character) do |reward|
        @rewards[key].call(reward) if @rewards[key]
      end
    end

    def preview_reward_on(key, character)
      RewardPreview.new(character) do |reward|
        @reward_previews[key].call(reward) if @rewards[key]
      end
    end
  end
end