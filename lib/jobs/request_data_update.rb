module Jobs
  class RequestDataUpdate < Struct.new(:request_id)
    def perform
      AppRequest::Base.find_by_id(request_id).try(:update_data!)
    end
  end
end