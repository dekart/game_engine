class PremiaController < ApplicationController
  def show
  end

  def update
    @result =
      case params[:type].to_sym
      when :buy_points
        current_character.buy_points!
      when :exchange_money
        current_character.exchange_money!
      when :refill_energy
        current_character.refill_energy!
      when :refill_health
        current_character.refill_health!
      else
        false
      end

    if @result
      flash[:success] = t("premia.update.messages.success.#{params[:type]}")
    else
      flash[:error] = t("premia.update.messages.failure")
    end

    redirect_to :action => :show
  end
end
