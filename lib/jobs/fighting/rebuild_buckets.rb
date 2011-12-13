module Jobs
  module Fighting
    class RebuildBuckets
      def perform
        puts "Rebuilding opponent buckets..."

        Benchmark.bm(25) do |b|
          b.report "Rebuilding buckets" do
            Fight::OpponentBuckets.rebuild!
          end
        end

        puts "Done! Total buckets: #{ Fight::OpponentBuckets.bucket_keys.size }"
      end
    end
  end
end