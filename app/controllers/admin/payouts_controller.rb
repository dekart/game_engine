class Admin::PayoutsController < ApplicationController
  def new
    @container = params[:container]
    @payout = Payouts::Base.by_name(params[:type]).new(nil)

    render :action => :new, :layout => "admin/ajax"
  end
end
