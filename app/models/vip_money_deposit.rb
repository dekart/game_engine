class VipMoneyDeposit < VipMoneyOperation
  PAYMENT_PROVIDERS = %w{offerpal super_rewards credits}

  after_create :deposit_money

  protected

  def deposit_money
    character.vip_money += amount

    character.save
  end
end
