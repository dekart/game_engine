class Admin::StatisticsController < Admin::BaseController
  def index
    @total_users    = User.count
    @last_day_users = User.count(:conditions => ["created_at >= ?", 24.hours.ago])
    @latest_users   = User.find(:all, :order => "created_at DESC", :limit => 100)

    @total_reference_stats  = User.reference_stats
    day_reference_stats     = User.reference_stats(24.hours.ago)

    @total_reference_stats.collect! do |name, count|
      [name, count, day_reference_stats.assoc(name).try(:last).to_i]
    end
  end
end
