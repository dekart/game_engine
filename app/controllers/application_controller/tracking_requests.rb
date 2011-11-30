class ApplicationController
  module TrackingRequests
    protected
    
    def tracking_requests
      if current_user && current_character
        $redis.zincrby("tracking_requests_#{Date.today}", 1, current_character.id)
      end
    end
  end
end