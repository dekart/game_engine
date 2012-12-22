module GameData
  class ItemSet
    class << self
      def sets
        @@sets ||= {}

        if @@sets.empty?
          # Load available encounters
          Dir[Rails.root.join('db/data/item_sets.rb')].each do |file|
            eval File.read(file)
          end
        end

        @@sets
      end

      def define(key, &block)
        @@sets[key] = new(key).tap(&block)
      end
    end

    attr_reader :key
    attr_accessor :items

    def initialize(key)
      @key = key
    end
  end
end