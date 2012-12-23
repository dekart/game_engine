module GameData
  class Base
    class << self
      def collection
        @collection ||= {}

        load! if @collection.empty?

        @collection
      end

      def define(key, &block)
        @collection[key] = new(key).tap(&block)
      end

      def [](key)
        collection[key]
      end
    end

    attr_reader :key
    attr_accessor :tags

    def initialize(key)
      @key = key
      @tags = []

      @rewards = {}
      @reward_previews = {}
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