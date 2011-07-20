namespace :app do
  namespace :market do
    desc "Remove expired market listings"
    task :remove_expired_listings => :environment do
      puts "Removing expired market listings (#{MarketItem.expired.count})..."

      MarketItem.transaction do
        MarketItem.expired.destroy_all
      end

      puts "Done"
    end
  end
end
