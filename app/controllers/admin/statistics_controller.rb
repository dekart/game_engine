class Admin::StatisticsController < Admin::BaseController
  def index
    @all = Statistics::Dashboard.new
    @day = Statistics::Dashboard.new(24.hours.ago)
    
    @complaints = Complaint.count
    @unread_complaints = Complaint.with_state(:unread).count
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
    @day  = params[:date] ? Date.parse(params[:date]) : Date.today
    @hour = params[:hour]
    
    result = @hour ? Statistics::Visits.visited_hourly_by_users(@day , @hour) : Statistics::Visits.visited_by_users(@day)
    
    ids = result.collect{|a| a[0]}
    @requests = result.collect{|a| a[1]}
    
    @total = @requests.sum
   
    @users = User.all(:conditions => {:id => ids}).sort_by{ |u| ids.index(u.id) }
    
    @users.insert(ids.index(0), nil) if ids.index(0) #Insert 'no user' value if present
  end
end
