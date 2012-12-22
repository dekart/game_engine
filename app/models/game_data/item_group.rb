module GameData
  class ItemGroup
    class << self
      def groups
        @@groups ||= {}

        if @@groups.empty?
          # Load available encounters
          Dir[Rails.root.join('db/data/item_groups.rb')].each do |file|
            eval File.read(file)
          end
        end

        @@groups
      end

      def define(key, &block)
        @@groups[key] = new(key).tap(&block)
      end
    end

    attr_reader :key
    attr_accessor :tags

    def initialize(key)
      @key = key
      @tags = []
    end
  end
end