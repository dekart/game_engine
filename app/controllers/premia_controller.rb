class PremiaController < ApplicationController
  def service
    render :layout => 'ajax'
  end

  def buy_vip
    render :json => {
      :packages => CreditPackage.with_state(:visible).map{ |package| package.as_json_for_purchase }
    }
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

  def refill
    case params[:type]
    when 'health'
      render :json => {
        :vip_money => Setting.i(:premium_health_price),
        :items => current_character.inventories.usable_with_payout(:health_point)
      }
    when 'energy'
      render :json => {
        :vip_money => Setting.i(:premium_energy_price),
        :items => current_character.inventories.usable_with_payout(:energy_point)
      }
    when 'stamina'
      render :json => {
        :vip_money => Setting.i(:premium_stamina_price),
        :items => current_character.inventories.usable_with_payout(:stamina_point)
      }
    end
  end
end
