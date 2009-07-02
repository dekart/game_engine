class Admin::PayoutsController < ApplicationController
  before_filter :admin_required

  def new
    @container = params[:container]
    @payout = Payouts::Base.by_name(params[:type]).new

    render :action => :new, :layout => "admin/ajax"
  end
end
