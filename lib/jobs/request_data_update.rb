module Jobs
  class RequestDataUpdate < Struct.new(:request_id)
    def perform
      recipient_ids = $redis.lrange("app_requests_#{request_id}", 0, -1)

      AppRequest::Base.check_request(request_id, recipient_ids)

      $redis.del("app_requests_#{request_id}")
    end
  end
end