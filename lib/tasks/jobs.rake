namespace :app do
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
  end
end