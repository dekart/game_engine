class Statistics
  class Visits < self
    class << self
      def track_visit(user)
        $redis.hincrby("tracking_requests_#{ Date.today }", user ? user.id : 0, 1)
      end
    
      def visited_by_users(date)
        $redis.hgetall("tracking_requests_#{ date }").to_a.tap do |result|
          result.map!{|id, value| [id.to_i, value.to_i] }
          result.sort!{|a, b| b[1] <=> a[1] }
        end
      end
    
      def average_amount(requests, date)
        "%.2f" % (requests.to_f / (date == Date.today ? Time.now.hour : 24))
      end
    end
  end
end