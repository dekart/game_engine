module GameData
  class Achievement < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/achievements/*.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    def initialize(key)
      super

      @placements = []
    end

    def condition(key, &block)
      @condition = block
    end

    def check(character)
      @condition.try(:call, character)
    end
  end
end