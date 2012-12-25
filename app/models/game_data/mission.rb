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
      @levels << GameData::MissionLevel.define("#{ @key }_level_#{ @levels.size }", &block).tap{|l| l.mission = self }
    end
  end
end