module Jobs
  class RequestDataUpdate < Struct.new(:request_id, :recipient_ids)
    def perform
      AppRequest::Base.check_request(request_id, recipient_ids)
    end
  end
end