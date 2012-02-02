class VipMoneyDeposit < VipMoneyOperation
  PAYMENT_PROVIDERS = %w{offerpal super_rewards credits}

  named_scope :purchases, :conditions => ["reference_type IN (?)", PAYMENT_PROVIDERS]

  after_create :deposit_money

  protected

  def deposit_money
    character.vip_money += amount

    character.save
  end
end
