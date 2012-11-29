class PremiaController < ApplicationController
  def service
    render :layout => 'ajax'
  end

  def buy_vip
    render :layout => 'ajax'
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
      when :change_name
        current_character.change_name!(params[:character][:name])
      else
        false
      end

    if @result
      flash.now[:success] = t("premia.update.messages.success.#{params[:type]}")
    end
  end

  def change_name
  end

  def refill_dialog
    @type = params[:type].to_sym
    @vip_money = refill_price(@type)
  end

  protected

  def refill_price(type)
    case type
    when :refill_stamina
      Setting.i(:premium_stamina_price)
    when :refill_health
      Setting.i(:premium_health_price)
    when :refill_energy
      Setting.i(:premium_energy_price)
    else
      0
    end
  end
end
