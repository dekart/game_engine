class VipMoneyOperationsController < ApplicationController
  skip_before_filter :check_character_existance, :ensure_canvas_connected_to_facebook

  def load_money
    on_valid_facebook_money_request do
      facebook_money_user.character.charge!(0, - facebook_money_amount, FacebookMoney.config["provider"])
    end
  end
end
