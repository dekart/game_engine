class Statistics
  class Visits < self
    def self.track_visit(current_user)
      if current_user
        $redis.zincrby("tracking_requests_#{Date.today}", 1, current_user.id)
      else
        $redis.zincrby("tracking_requests_#{Date.today}", 1, 0)
      end
    end
    
    def self.visited_by_users(date)
      $redis.zrevrange("tracking_requests_#{date}", 0, -1, :with_scores => true).collect{|v| v.to_i}.in_groups_of(2)
    end
    
    def self.average_amount(requests, date)
      "%.2f" % (requests.to_f / (date == Date.today ? Time.now.hour : 24))
    end
  end
end