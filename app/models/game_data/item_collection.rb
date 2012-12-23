module GameData
  class ItemCollection < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/item_collections/**/*.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    attr_accessor :items
  end
end