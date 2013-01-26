module Jobs
  class RequestDelete
    def perform
      return if $redis.get('app_requests_last_processed_at').to_i > 10.seconds.ago

      begin
        request_ids = $redis.smembers("app_requests_for_deletion")[0..40]

        request_ids.each{|id| $redis.srem("app_requests_for_deletion", id)}

        batch_result = AppRequest::Base.delete_from_facebook!(request_ids)

        batch_result.each_with_index do |result, index|
          $redis.sadd("app_requests_failed_deletion", request_ids[index]) if result == false
        end

        $redis.set("app_requests_last_processed_at", Time.now.to_i)
      end while request_ids.size > 0
    end
  end
end