class Admin::PayoutsController < ApplicationController
  before_filter :admin_required

  def new
    @container = params[:container].camelcase.constantize
    
    @payout = Payouts::Base.by_name(params[:type]).new(
      :apply_on => @container.payout_options[:default_event]
    )

    render :action => :new, :layout => "admin/ajax"
  end
end
