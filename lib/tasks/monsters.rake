namespace :app do
  namespace :monsters do
    desc "Expire timed out monsters"
    task :expire => :environment do
      Jobs::Monsters::Expire.new.perform
    end
  end
end