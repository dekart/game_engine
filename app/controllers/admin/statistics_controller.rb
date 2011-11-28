class Admin::StatisticsController < Admin::BaseController
  def index
    @all = Statistics::Dashboard.new
    @day = Statistics::Dashboard.new(24.hours.ago)
  end

  def user
    @all = Statistics::Users.new
    @day = Statistics::Users.new(24.hours.ago)
    @month = Statistics::Users.new(30.days.ago.beginning_of_day)
  end
  
  def level
    @filter = Statistics::Levels::FILTERS.include?(params[:filter]) ? params[:filter] : 'all'
    
    @stats = Statistics::Levels.new(Statistics::Levels.time_frame_by_filter(@filter))
  end

  def vip_money
    @all = Statistics::VipMoney.new
    @day = Statistics::VipMoney.new(24.hours.ago)
  end
  
  def visits
    @day = params[:date] ? Date.parse(params[:date]) : Date.today
    
    result = Statistics::Visits.visited_by_characters(@day)
    
    ids = result.collect{|a| a[0]}
    @requests = result.collect{|a| a[1]}
    
    @total = @requests.inject(0){|result, elem| result + elem}
    
    @characters = Character.find(ids).sort_by{|c| ids.index{|i| i == c.id } }
  end
end
