class CreditOrdersController < ApplicationController
  skip_authentication_filters
  skip_before_filter :tracking_requests, :check_standalone

  def create
    data = Facepalm::User.parse_signed_request(facepalm, params[:signed_request])

    time, character_id, package_id = data["request_id"].split(':')

    @order = CreditOrder.where(facebook_id: data["payment_id"]).first_or_initialize(
      character_id: character_id,
      package_id:   package_id
    )

    if data["status"] == "completed"
      @order.complete
    else
      @order.save!
    end

    render :json => {
      :status => @order.state,
      :vip_money => @order.package.vip_money
    }
  end

  def show
    @package = CreditPackage.find(params[:id])

    render :layout => false
  end

  def subscribe
    if request.get?
      render :text => Koala::Facebook::RealtimeUpdates.meet_challenge(params, facepalm.subscription_token)
    elsif request.post?
      facebook_ids = params[:entry].collect{|e| e['id'] }

      Delayed::Job.enqueue Jobs::ProcessPayments.new(facebook_ids)

      render :text => 'OK'
    end
  end
end
