class Statistics
  class Dashboard < self
    attr_reader :users, :vip_money

    def initialize(*args)
      super(*args)

      @users = Users.new(@time_range)
      @vip_money = VipMoney.new(@time_range)
    end
    
    def scope=(value)
      @scope = value
    end
  end
end
