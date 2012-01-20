class VipMoneyWithdrawal < VipMoneyOperation
  after_create :withdraw_money

  validate :validate_enough_amount, :on => :create

  protected

  def validate_enough_amount
    errors.add(:amount, :not_enough) if amount && amount > character.vip_money
  end

  def withdraw_money
    character.vip_money -= amount

    character.save!
  end
end
