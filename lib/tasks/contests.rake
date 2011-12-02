namespace :app do
  namespace :contests do
    desc "Finish current contests"
    task :finish => :environment do
      Jobs::Contests::Finish.new.perform
    end
  end
end