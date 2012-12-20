module Jobs
  class RequestDelete
    def perform
      request_ids = $redis.smembers("app_requests_for_deletion")

      request_ids.each_slice(50) do |ids|
        requests = AppRequest::Base.find_all_by_id(ids)
        graph_api_ids = requests.collect{|request| request.graph_api_id }

        batch_result = AppRequest::Base.delete_from_facebook!(graph_api_ids)

        batch_result.each_with_index do |result, index|
          $redis.srem("app_requests_for_deletion", requests[index].id)

          if result != true
            requests[index].mark_broken! if requests[index].can_mark_broken?

            $redis.sadd("app_requests_failed_deletion", requests[index].id)
          end
        end
      end
    end
  end
end