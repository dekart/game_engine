module GameData
  class PropertyType < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/property/*.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    attr_accessor :upgrades, :collect_period, :workers
  end
end