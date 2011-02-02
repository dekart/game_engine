module Jobs
  class RequestDataUpdate < Struct.new(:request_id)
    def perform
      AppRequest.find(request_id).update_data!
    end
  end
end