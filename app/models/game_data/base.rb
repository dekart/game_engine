module GameData
  class Base
    class << self
      def collection
        @collection ||= {}

        load! if @collection.empty?

        @collection
      end

      def define(key, &block)
        @collection ||= {}
        @id_to_key = nil
        @collection[key] = new(key).tap(&block)
      end

      def [](key)
        case key
        when Symbol
          collection[key]
        when Numeric
          collection[id_to_key[key]]
        when String
          if key =~ /^[0-9]+$/
            collection[id_to_key[key.to_i]]
          else
            collection[key.to_sym]
          end
        end
      end

      def id_to_key
        @id_to_key ||= {}.tap do |hash|
          collection.each do |key, object|
            hash[object.id] = key
          end
        end
      end
    end

    attr_reader :key
    attr_accessor :tags

    def initialize(key)
      @key = key
      @tags = []

      @rewards = {}
      @reward_previews = {}
      @requirements = {}
      @visible_if = nil
    end

    def id
      @id ||= Zlib.crc32(to_key)
    end

    def to_key
      "#{ self.class.name.demodulize.underscore }_#{ @key }"
    end

    def picture(size, format = 'jpg')
      "#{ self.class.name.demodulize.underscore }/#{ @key }/#{ size }.#{ format }"
    end

    def reward_on(key, &block)
      @rewards[key] = block
    end

    def reward_preview_on(key, &block)
      @reward_previews[key] = block
    end

    def apply_reward_on(key, character)
      Reward.new(character) do |reward|
        @rewards[key].try(:call, reward)
      end
    end

    def preview_reward_on(key, character)
      RewardPreview.new(character) do |reward|
        (@reward_previews[key] || @rewards[key]).try(:call, reward)
      end
    end

    def requires_for(trigger, &block)
      @requirements[trigger] = block
    end

    def requirements_for(character, trigger)
      Requirement.new(character) do |r|
        @requirements[trigger].try(:call, r)
      end
    end

    def requires(&block)
      requires_for(:base, &block)
    end

    def requirements(character)
      requirements_for(character, :base)
    end

    def visible_if(&block)
      @visible_if = block
    end

    def visible?(character)
      @visible_if ? @visible_if.call(character) : true
    end
  end
end