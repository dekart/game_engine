namespace :blogbox do
  namespace :jobs do
    desc "Re-setup user profiles"
    task :setup_profiles => :environment do
      User.all.each do |user|
        Delayed::Job.enqueue Jobs::SetupProfile.new(user.id)
      end
    end

    desc "Update user profiles"
    task :update_profiles => :environment do
      User.all.each do |user|
        Delayed::Job.enqueue Jobs::UpdateProfile.new(user.id)
      end
    end

    desc "Update references"
    task :update_references => :environment do
      Net::HTTP.get_response(URI.parse(Facebooker.facebooker_config["callback_url"]))

      Jobs::UpdateReferences.new.perform
    end
  end
end