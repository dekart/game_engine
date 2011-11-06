class Character
  module AppRequests
    def app_requests
      @app_requests ||= AppRequest::Base.for_character(self)
    end
  end
end