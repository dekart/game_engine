class BoostsController < ApplicationController
  def index
    @boosts = Boost.with_state(:visible).paginate(:page => params[:page], :per_page => 10)
  end
end
