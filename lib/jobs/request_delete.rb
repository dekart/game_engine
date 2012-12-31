module Jobs
  class RequestDelete
    def perform
      request_ids = $redis.smembers("app_requests_for_deletion")

      request_ids.each_slice(50) do |ids|
        batch_result = AppRequest::Base.delete_from_facebook!(ids)

        batch_result.each_with_index do |result, index|
          $redis.srem("app_requests_for_deletion", ids[index])

          $redis.sadd("app_requests_failed_deletion", ids[index]) unless result
        end
      end

      $redis.set("app_requests_last_processed_at", Time.now.to_i)
    end
  end
end