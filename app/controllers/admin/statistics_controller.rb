class Admin::StatisticsController < Admin::BaseController
  def index
    @statistics = Statistics::Dashboard.new(24.hours)
  end

  def user
    @statistics = Statistics::Users.new(24.hours)
  end

  def vip_money
    @total_deposit  = VipMoneyDeposit.sum(:amount)
    @total_withdraw = VipMoneyWithdrawal.sum(:amount)

    
  end
end
