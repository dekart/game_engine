namespace :app do
  namespace :fighting do
    desc "Rebuild opponent buckets"
    task :rebuild_buckets => :environment do
      puts
      puts "Opponent bucket rebuild started at #{ Time.now}"
      puts
      
      Benchmark.bm(25) do |b|
        b.report "Rebuilding buckets" do
          Fight::OpponentBuckets.rebuild!
        end
      end
      
      puts
      puts "Done! Total buckets: #{ Fight::OpponentBuckets.bucket_keys.size }"
      puts
    end
  end
end