class Admin::StatisticsController < Admin::BaseController
  def index
    @total_users    = User.count
    @last_day_users = User.count(:conditions => ["created_at >= ?", 24.hours.ago])
    @latest_users   = User.find(:all, :order => "created_at DESC", :limit => 100)
  end
end
