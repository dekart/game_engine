class Admin::StatisticsController < Admin::BaseController
  def index
    @all = Statistics::Dashboard.new
    @day = Statistics::Dashboard.new(24.hours.ago)

    @complaints = Complaint.count
    @unread_complaints = Complaint.with_state(:unread).count

    @delayed_jobs = {
      :total => Delayed::Job.count,
      :failed => Delayed::Job.where("last_error IS NOT NULL").count
    }

    @scheduler = $redis.hgetall(:scheduler).to_options.tap do |s|
      s[:total_tasks] = s[:total_tasks].to_i
      s[:started_at] = Time.at(s[:started_at].to_i) unless s[:started_at].blank?
      s[:finished_at] = Time.at(s[:finished_at].to_i) unless s[:finished_at].blank?
    end

    @app_requests = {
      :sent_all => AppRequest::Base.count,
      :sent_today => AppRequest::Base.sent_after(24.hours.ago).count,

      :by_state_all => AppRequest::Base.group(:state).count,
      :by_state_today => AppRequest::Base.sent_after(24.hours.ago).group(:state).count,

      :for_deletion => $redis.scard("app_requests_for_deletion"),
      :failed => $redis.scard("app_requests_failed_deletion"),
      :random_failed => $redis.srandmember("app_requests_failed_deletion"),
      :last_processed_at => $redis.get("app_requests_last_processed_at").to_i,
    }
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

  def payments
    @keys = $redis.keys("payment_by_reference_*")

    key = params[:key] || @keys.max
    @result = key ? Marshal.load($redis.get(key)) : []

    @result.sort!{|a, b| b[:users_amount] <=> a[:users_amount] } # sort by number of users

    @result
  end

  def retention
    @keys = $redis.keys("retention_by_reference_*")

    key = params[:key] || @keys.max
    @result = key ? Marshal.load($redis.get(key)) : []

    @result.sort!{|a, b| b[:users_amount] <=> a[:users_amount] } # sort by number of users

    @result
  end

  def sociality
    @keys = $redis.keys("sociality_by_reference_*")

    key = params[:key] || @keys.max
    @result = key ? Marshal.load($redis.get(key)) : []

    @result.sort!{|a, b| b[:users_amount] <=> a[:users_amount] } # sort by number of users

    @result
  end

  def generate_statistics
    case params[:type]
    when "payments"
      Delayed::Job.enqueue Jobs::Statistic::GeneratePayments.new
    when "retention"
      Delayed::Job.enqueue Jobs::Statistic::GenerateRetention.new
    when 'sociality'
      Delayed::Job.enqueue Jobs::Statistic::GenerateSociality.new
    end

    respond_to do |format|
      format.js {render :generate}
    end
  end
end