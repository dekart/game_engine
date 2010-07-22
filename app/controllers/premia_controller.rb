class PremiaController < ApplicationController
  skip_landing_redirect

  def show
    @special_items = Item.with_state(:visible).available.available_in(:special).available_for(current_character).all(
      :limit => 3,
      :order => "RAND()"
    )
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
      when :refill_stamina
        current_character.refill_stamina!
      when :hire_mercenary
        current_character.hire_mercenary!
      when :reset_attributes
        current_character.reset_attributes!
      else
        false
      end

    flash[:class] = :premia
    
    if @result
      flash[:success] = t("premia.update.messages.success.#{params[:type]}")
    else
      flash[:error] = t("premia.update.messages.failure")
    end

    redirect_to premium_path
  end
end
