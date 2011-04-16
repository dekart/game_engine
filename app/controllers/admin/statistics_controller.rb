class Admin::StatisticsController < Admin::BaseController
  def index
    @all = Statistics::Dashboard.new
    @day = Statistics::Dashboard.new(24.hours.ago)
  end

  def user
    @all = Statistics::Users.new
    @day = Statistics::Users.new(24.hours.ago)
    @week = Statistics::Users.new(7.days.ago.beginning_of_day)
  end
  
  def level
    @filter = Statistics::Levels::FILTERS.include?(params[:filter]) ? params[:filter] : 'all'
    
    @stats = Statistics::Levels.new(Statistics::Levels.time_frame_by_filter(@filter))
  end

  def vip_money
    @all = Statistics::VipMoney.new
    @day = Statistics::VipMoney.new(24.hours.ago)
  end
end
