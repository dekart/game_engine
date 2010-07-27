class Statistics
  class Users < self
    def total_users
      User.count
    end

    def users_by_period
      User.count(:conditions => ["created_at >= ?", @period.ago])
    end

    def latest_users(limit = 100)
      User.all(
        :include  => {:character => :character_type},
        :order    => "created_at DESC",
        :limit    => limit
      )
    end

    def references
      totals = User.all(
        :select => "reference, count(id) as user_count",
        :group  => :reference,
        :order  => :reference
      )

      totals.collect!{|c| [c.reference, c[:user_count].to_i] }

      by_period = User.scoped(:conditions => ["created_at >= ?", @period.ago]).all(
        :select => "reference, count(id) as user_count",
        :group  => :reference,
        :order  => :reference
      )

      by_period.collect!{|c| [c.reference, c[:user_count].to_i] }

      totals.collect do |name, count|
        [name, count, by_period.assoc(name).try(:last).to_i]
      end
    end
  end
end