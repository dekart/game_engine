class Statistics
  class Users < self
    def default_scope
      @time_range ? User.where(["users.created_at BETWEEN ? AND ?", @time_range.begin, @time_range.end]) : User
    end

    def total_users
      scope.count
    end

    def recent_visitors(time = 7.days)
      scope.where(["last_visit_at > ?", time.ago])
    end

    def users_by_day
      [].tap do |result|
        numeric_time_range.step(1.day) do |seconds|
          time = Time.at(seconds)

          result << [
            time.to_date,
            scope.where('users.created_at BETWEEN ? AND ?', time.beginning_of_day, time.end_of_day).count
          ]
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
