module GameData
  class MonsterType < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/monsters/*.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    attr_accessor :level, :fight_time, :respawn_time, :health, :damage, :response, :reward_collectors, :effects

    def initialize(key)
      super

      @effects = {}
    end
  end
end