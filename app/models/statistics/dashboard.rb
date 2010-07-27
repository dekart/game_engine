class Statistics
  class Dashboard < self
    attr_reader :users

    delegate :total_users, :users_by_period, :to => :users

    def initialize(*args)
      super(*args)

      @users = Users.new(@period)
    end

    
  end
end