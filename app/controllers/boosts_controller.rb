class BoostsController < ApplicationController
  def index
    @boosts = Boost.paginate(:page => params[:page], :per_page => 10)
  end
end
