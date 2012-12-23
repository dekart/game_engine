module GameData
  class MissionGroup < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/mission_groups.rb')].each do |file|
          eval File.read(file)
        end
      end
    end
  end
end