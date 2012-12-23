module GameData
  class ItemGroup < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/item_groups.rb')].each do |file|
          eval File.read(file)
        end
      end
    end
  end
end