class BoostsController < ApplicationController
  def index
    @item_groups = ItemGroup.with_state(:visible).visible_in_shop
    @boosts = Boost.with_state(:visible).paginate(:page => params[:page], :per_page => 10)
  end
end
