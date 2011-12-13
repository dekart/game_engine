class Fight
  module OpponentBuckets
    BUCKET_SIZE = 200

    class << self
      def rebuild!
        new_bucket_keys = []
        
        Fight::OPPONENT_LEVEL_RANGES.reverse.each do |range| # Process in reversed order to rebuild small top-level buckets first
          # Building a list of IDs of characters
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
            opponents_per_bucket = ids.size + 1 # Bucket size cannot be zero
          end

          buckets = (ids.size.to_f / opponents_per_bucket).ceil # calculating number of buckets for current range

          # Storing ids in redis splitted by buckets
          buckets.times do |bucket|
            new_bucket_keys << bucket_key(range.begin, bucket)
            
            ids.slice!(0, opponents_per_bucket).each do |id|
              $redis.sadd('new_' + new_bucket_keys.last, id) # TODO: Use batch add after migration to new redis gem
            end
          end

          # Storing number of buckets for current range
          $redis.hset("new_opponent_buckets", range.begin, buckets)
        end
        
        (new_bucket_keys + ['opponent_buckets']).each do |key|
          $redis.rename('new_' + key, key)
        end
        
        true
      end
      
      def opponent_ids(range, bucket)
        $redis.smembers(bucket_key(range.begin, bucket)).map{|i| i.to_i }
      end
      
      def random_opponents(range, exclude_ids, amount)
        total_buckets = buckets[range.begin] || 0
        current_bucket = rand(total_buckets)
        
        result = []
        buckets_processed = 0
        
        while buckets_processed < total_buckets && result.size < amount
          result.push(*(opponent_ids(range, current_bucket) - exclude_ids))
          
          current_bucket += 1
          current_bucket = 0 if current_bucket >= total_buckets

          buckets_processed += 1
        end
        
        result.shuffle!
        
        result[0, amount]
      end
      
      def bucket_key(level, bucket)
        "opponent_bucket_#{ level }_#{ bucket }"
      end
      
      def buckets
        $memory_store.fetch('opponent_buckets', :expires_in => 30.seconds) do
          {}.tap do |result|
            $redis.hgetall("opponent_buckets").each do |key, value| 
              result[key.to_i] = value.to_i
            end
          end
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