class PremiaController < ApplicationController
  def show
  end

  def buy_money
    current_character.exchange_money!

    redirect_to :action => :show
  end

  def refill_energy
    current_character.refill_energy!

    redirect_to :action => :show
  end

  def refill_health
    current_character.refill_health!

    redirect_to :action => :show
  end

  def buy_points
    current_character.buy_points!

    redirect_to :action => :show
  end
end
