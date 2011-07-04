class VipMoneyOperationsController < ApplicationController
  skip_authentication_filters

  def load_money
    on_valid_facebook_money_request do |user_id, amount|
      Character.find(user_id).charge!(0, - amount, FacebookMoney.config["provider"])
    end
  end
end
