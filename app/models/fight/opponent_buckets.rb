class Fight
  module OpponentBuckets
    BUCKET_SIZE = 200

    class << self
      def rebuild!
        clear!
      
        Fight::OPPONENT_LEVEL_RANGES.reverse.each do |range| # Process in reversed order to rebuild small top-level buckets first
          rebuild_by_range(range)
        end
        
        buckets
      end
    
      def rebuild_by_range(range)
        ids = Character.connection.select_values(
          Character.send(:sanitize_sql_array,
            [
              "SELECT id FROM characters WHERE level BETWEEN ? AND ? AND fighting_available_at < ?",
              range.begin,
              range.end,
              Time.now.utc
            ]
          )
        )
        ids.map!{|i| i.to_i }
        
        ids -= Character.banned_ids
        ids.shuffle!
      
        # Calculating number of opponents per bucket
        if (ids.size.to_f / BUCKET_SIZE).round > 1 # There are more than bucket_size*1.5 opponents
          opponents_per_bucket = (ids.size.to_f / (ids.size.to_f / BUCKET_SIZE).ceil).ceil
        else
          opponents_per_bucket = ids.size
        end
      
        buckets = (ids.size.to_f / opponents_per_bucket).ceil # calculating number of buckets for current range
      
        # Storing ids in redis splitted by buckets
        buckets.times do |bucket|
          ids.slice!(0, opponents_per_bucket).each do |id|
            $redis.sadd(bucket_key(range.begin, bucket), id)
          end
        end
      
        # Storing number of buckets for current range
        $redis.hset("opponent_buckets", range.begin, buckets)
      end
      
      def opponent_ids(range, bucket)
        $redis.smembers(bucket_key(range.begin, bucket)).map{|i| i.to_i }
      end
      
      def random_opponents(range, exclude_ids, amount)
        total_buckets = buckets[range.begin] || 0
        bucket = rand(total_buckets)
        
        result = []
        buckets_processed = 0
        
        while result.size < amount && buckets_processed < total_buckets
          buckets_processed += 1
          
          result.push(*(opponent_ids(range, bucket) - exclude_ids))
          
          bucket += 1
          bucket = 0 if bucket >= total_buckets
        end
        
        result.shuffle!
        
        result[0, amount]
      end
      
      def bucket_key(level, bucket)
        "opponent_bucket_#{ level }_#{ bucket }"
      end
      
      def buckets
        $memory_store.fetch('opponent_buckets', :expires_in => 30.seconds) do
          $redis.hgetall("opponent_buckets").inject({}){|memo, (key, value)| memo[key.to_i] = value.to_i; memo }
        end
      end
      
      def bucket_keys
        [].tap do |result|
          buckets.map do |level, amount|
            amount.times do |bucket|
              result << bucket_key(level, bucket)
            end
          end
        end
      end
      
      def delete(character)
        id = character.id
        
        bucket_keys.each do |key|
          return true if $redis.srem(key, id)
        end
        
        false
      end
      
      def update(character)
        delete(character)
        
        range = Fight.level_range(character)
        
        if max_bucket = buckets[range.begin] # Only try to add to bucket if we have any buckets for desired level range
          key = bucket_key(range.begin, max_bucket > 1 ? rand(max_bucket) : 0)

          $redis.sadd(key, character.id)
        end
      end
      
      def clear!
        $redis.keys('opponent_bucket*').each do |key|
          $redis.del(key)
        end
      end
    end
  end
end