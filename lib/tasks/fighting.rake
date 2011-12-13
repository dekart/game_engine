namespace :app do
  namespace :fighting do
    desc "Rebuild opponent buckets"
    task :rebuild_buckets => :environment do
      Jobs::Fighting::RebuildBuckets.new.perform
    end
  end
end