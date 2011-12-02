module Jobs
  module Market
    class RemoveExpiredListings
      def perform
        puts "Removing expired market listings (#{ MarketItem.expired.count })..."

        MarketItem.expired.destroy_all

        puts "Done!"
      end
    end
  end
end