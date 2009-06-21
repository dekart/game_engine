class PremiaController < ApplicationController
  def show
  end

  def buy_money
    current_character.exchange_money!

    redirect_to :action => :show
  end
end
