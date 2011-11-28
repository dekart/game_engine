class Statistics
  class Visits < self
    
    def self.visited_by_characters(date)
      $redis.zrevrange("tracking_requests_#{date}", 0, -1, :with_scores => true).collect{|v| v.to_i}.in_groups_of(2)
    end
    
    def self.average_amount(requests, date)
      "%.2f" % (requests.to_f / (date == Date.today ? Time.now.hour : 24))
    end
  end
end