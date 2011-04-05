class Statistics
  class Users < self
    def default_scope
      @time_range ? User.scoped(:conditions => ["users.created_at BETWEEN ? AND ?", @time_range.begin, @time_range.end]) : User
    end
        
    def total_users
      scope.count
    end
    
    def users_by_day
      [].tap do |result|
        numeric_time_range.step(1.day) do |seconds|
          time = Time.at(seconds)
          
          result << [time.to_date, scope.count(:conditions => ['users.created_at BETWEEN ? AND ?', time, time.end_of_day])]
        end
      end
    end

    def references
      scope.all(
        :select => "reference, count(id) as user_count",
        :group  => :reference,
        :order  => :reference
      ).collect!{|c| [c.reference, c[:user_count].to_i] }
    end
  end
end
