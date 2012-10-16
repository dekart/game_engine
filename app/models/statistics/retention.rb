class Statistics
  class Retention < self
    def reference_types
      result = User.all(
        :select => "reference, count(*) as total_amount",
        :group  => :reference,
        :order  => :reference
      )

      result.collect!{|d| [d[:reference], d[:total_amount].to_i] }

      result
    end

    def returned_users
      total = User.all(
        :select => "reference, count(*) as total_amount",
        :conditions => ["datediff(last_visit_at, created_at) > 7"],
        :group  => :reference,
        :order  => :reference
      )

      {}.tap do |result|
        total.each do |d|
          result[d[:reference]] = d[:total_amount].to_i
        end
      end
    end

    def users_reached_level(level)
      total = User.joins(:character).all(
        :select => "reference, count(*) as total_amount",
        :conditions => ["characters.level >= ?", level],
        :group  => :reference,
        :order  => :reference
      )

      {}.tap do |result|
        total.each do |d|
          result[d[:reference]] = d[:total_amount].to_i
        end
      end
    end
  end
end