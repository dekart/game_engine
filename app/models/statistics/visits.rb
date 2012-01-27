class Statistics
  class Visits < self
    class << self
      def track_visit(user)
        $redis.hincrby("tracking_requests_#{ Date.today }", user ? user.id : 0, 1)
      end
      
      def track_visit_hourly(user)
        $redis.hincrby("tracking_requests_hourly_#{ Date.today }_#{ Time.now.hour }", user ? user.id : 0, 1)
      end
    
      def visited_by_users(date = Date.today)
        $redis.hgetall("tracking_requests_#{ date }").to_a.tap do |result|
          result.map!{|id, value| [id.to_i, value.to_i] }
          result.sort!{|a, b| b[1] <=> a[1] }
        end
      end
      
      def visited_hourly_by_users(date, hour)
        $redis.hgetall("tracking_requests_hourly_#{ date }_#{ hour }").to_a.tap do |result|
          result.map!{|id, value| [id.to_i, value.to_i] }
          result.sort!{|a, b| b[1] <=> a[1] }
        end
      end
      
      def visited_by_user(user, date = Date.today)
        $redis.hget("tracking_requests_#{ date }", user.id).to_i
      end
    
      def average_amount(requests, date)
        "%.2f" % (requests.to_f / (date == Date.today ? Time.now.hour : 24))
      end
    end
  end
end