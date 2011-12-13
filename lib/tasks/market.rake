namespace :app do
  namespace :market do
    desc "Remove expired market listings"
    task :remove_expired_listings => :environment do
      Jobs::Market::RemoveExpiredListings.new.perform
    end
  end
end
