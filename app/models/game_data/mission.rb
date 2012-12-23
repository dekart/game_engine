module GameData
  class Mission < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/missions/**/*.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    attr_reader :levels

    def initialize(key)
      super

      @levels = []
    end

    def group=(value)
      @group_id = value
    end

    def group
      Data::MissionGroup.groups[@group_id]
    end

    def level(&block)
      @levels << GameData::MissionLevel.new(self, @levels.size).tap(&block)
    end
  end
end