module Jobs
  class RequestDelete
    def perform
      begin
        request_ids = $redis.smembers("app_requests_for_deletion")[0..200]

        request_ids.each{|id| $redis.srem("app_requests_for_deletion", id)}

        request_ids.each_slice(50) do |ids|
          batch_result = AppRequest::Base.delete_from_facebook!(ids)

          batch_result.each_with_index do |result, index|
            $redis.sadd("app_requests_failed_deletion", ids[index]) unless result
          end
        end
      end while request_ids.size > 0

      $redis.set("app_requests_last_processed_at", Time.now.to_i)
    end
  end
end