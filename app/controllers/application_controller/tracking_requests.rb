class ApplicationController
  module TrackingRequests
    protected
    
    def tracking_requests
      Statistics::Visits.track_visit(current_user) 
    end
  end
end