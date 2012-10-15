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
    all = Statistics::Payments.new
    reference_types = all.reference_types

    payments = {}
    reference_types.collect{|a| a[0]}.each do |reference|
      payments[reference] = all.total_payments_by_reference(reference)
    end

    @result = reference_types.collect do |name, users_count, paying_count|
      {:name => name.to_s, :users_amount => users_count, :paying_amount => paying_count, :payments_amount => payments[name].to_i}
    end

    @result.sort!{|a, b| b[:users_amount] <=> a[:users_amount] } # sort by number of users

    @result
  end

  def retention
  end
  
  def sociality
  end
end