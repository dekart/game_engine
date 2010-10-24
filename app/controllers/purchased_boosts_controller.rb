class PurchasedBoostsController < ApplicationController
  def create
    @amount = params[:amount].to_i
    @boost = Boost.find(params[:boost_id])

    if @enough_money = current_character.purchased_boosts.enough_money_for(@boost, @amount)
      current_character.purchased_boosts.buy!(@boost, @amount)
    end

    render :action => :create, :layout => "ajax"
  end
end
