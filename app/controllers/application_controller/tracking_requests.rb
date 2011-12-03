class ApplicationController
  module TrackingRequests
    def self.included(base)
      base.class_eval do
        before_filter :tracking_requests 
      end
    end
    
    protected
    
    def tracking_requests
      Statistics::Visits.track_visit(current_user) 
    end
  end
end