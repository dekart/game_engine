namespace :app do
  namespace :users do
    desc "Set up 'installed' flag for users"
    task :installed => :environment do
      api_client = Facepalm::Config.default.api_client
      i = 0

      User.find_in_batches(:batch_size => 100) do |users|

        User.transaction do
          begin
            user_ids = users.collect{|u| u.facebook_id }
  
            result = api_client.get_objects(user_ids, :fields => [:installed])
  
            result.each do |facebook_id, facebook_data|
              if facebook_data["installed"] != true
                user = users.detect{|u| u.facebook_id == facebook_id.to_i }
  
                user.update_attribute(:installed, false)
              end
  
              i += 1
              puts "Processed #{i}..." if i % 100 == 0
            end
          rescue Koala::Facebook::APIError => e
            Rails.logger.error e
          end
        end
      end

      puts "Done"
    end
  end
end