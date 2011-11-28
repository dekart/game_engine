class ApplicationController
  module TrackingRequests
    protected
    
    def tracking_requests
      if current_user
        if $redis.zscore("tracking_requests_#{Date.today}", current_character.id)
          $redis.zincrby("tracking_requests_#{Date.today}", 1, current_character.id)
        else
          $redis.zadd("tracking_requests_#{Date.today}",1, current_character.id)
        end
      end
    end
  end
end