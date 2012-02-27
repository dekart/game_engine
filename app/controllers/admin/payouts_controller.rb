class Admin::PayoutsController < Admin::BaseController
  def new
    @container = params[:container].camelcase.constantize

    @payout = Payouts::Base.by_name(params[:type]).new(
      @container.payout_options
    )
  end
end
