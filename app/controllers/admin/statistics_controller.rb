class Admin::StatisticsController < ApplicationController
  def index
    @total_users = User.count
    @latest_users = User.find(:all, :order => "created_at DESC", :limit => 10)
  end
end
