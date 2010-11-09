class Admin::PayoutsController < Admin::BaseController
  def new
    @container = params[:container].camelcase.constantize

    @payout = Payouts::Base.by_name(params[:type]).new(
      :apply_on => @container.payout_options[:default_event]
    )

    render :layout => :ajax_layout
  end
end
