class ApplicationController
  module TrackingRequests
    protected
    
    def tracking_requests
      if current_user
        $redis.zincrby("tracking_requests_#{Date.today}", 1, current_user.facebook_id)
      else
        $redis.zincrby("tracking_requests_#{Date.today}", 1, 0)
      end 
    end
  end
end